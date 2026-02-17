IF EXISTS (
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_CO_ConsultaRegistrosGastosPorFechas'
)
    DROP PROCEDURE sp_CO_ConsultaRegistrosGastosPorFechas;
GO

CREATE PROCEDURE [dbo].[sp_CO_ConsultaRegistrosGastosPorFechas]
    @FechaMes   DATETIME,
    @IdContrato INT,
    @IdUsuario  INT
AS
BEGIN
    DECLARE @FechaInicio DATETIME,
            @FechaFin DATETIME,
            @DiaActual DATE = GETDATE(),
            @NombreAreaContractual VARCHAR(100) = '',
            @NombreEstadoInicialAmatitlan VARCHAR(100) = 'Revisión';

    SET NOCOUNT ON;
    SET LANGUAGE spanish;

    /* =========================================================
       TABLAS TEMP
       ========================================================= */
    CREATE TABLE #CartasProcura
    (
        IdFacutraP INT,
        UUID       VARCHAR(100),
        IdFactura  INT
    );

    CREATE TABLE #MesesAnio
    (
        Id INT IDENTITY(1, 1),
        PrimerDiaMes DATE,
        UltimoDiaMes DATE,
        SiguienteMesSeis DATE
    );

    CREATE TABLE #Datos
    (
        IdRegistro INT,
        Servicio VARCHAR(1000),
        InstalacionPresupuestada VARCHAR(1000),
        FechaInicio DATE,
        FechaFin DATE,
        TipoDocumento VARCHAR(100),
        Numero VARCHAR(500),
        FechaDocumento DATETIME,
        MontoUSD FLOAT,

        TipoCambioUsado  DECIMAL(18,6) NULL,
        UsaTCMesAnterior BIT NULL,

        Subcontratista VARCHAR(1000),
        InstalacionRegistro VARCHAR(500),
        InicioEjecucion DATE,
        FinEjecucion DATE,
        CreadoPor VARCHAR(500),
        MontoRegistro FLOAT,
        Moneda VARCHAR(50),
        MesPresentacion DATE,
        Anio INT,
        Mes VARCHAR(500),
        TipoDeServicio VARCHAR(500),
        Actividad VARCHAR(1000),
        SubActividad VARCHAR(1000),
        EstadoValidacion VARCHAR(500),
        Area VARCHAR(500),
        Comentarios VARCHAR(5000),
        Anexo4 VARCHAR(500),
        Identificador INT,
        LineaPresupuesto INT,
        Presupuesto VARCHAR(1000),
        Rubro VARCHAR(500),
        CatManoObra VARCHAR(500),
        PCN FLOAT,
        CAA VARCHAR(500),
        CCN VARCHAR(500),
        ModificadoPor VARCHAR(500)
    );

    /* =========================================================================
       - #TCMensual se crea SIEMPRE, para evitar error de compilación cuando NO es CIEP.
       - Si NO es CIEP, la tabla queda vacía (no afecta porque los JOIN tienen ON @EsCIEP = 1).
       ========================================================================= */
    CREATE TABLE #TCMensual
    (
        AnioTC INT NOT NULL,
        MesTC  INT NOT NULL,
        TipoCambio DECIMAL(18,6) NULL,
        ObtenidoSDK BIT NULL,
        CONSTRAINT PK_TCMensual PRIMARY KEY (AnioTC, MesTC)
    );

    /* =========================================================
       Area contractual
       ========================================================= */
    SELECT TOP 1
        @NombreAreaContractual = ISNULL(AC.NombreAreaContractual, '')
    FROM CO_Contrato C (NOLOCK)
    JOIN CO_AreaContractual AC (NOLOCK)
        ON C.IdAreaContractual = AC.IdAreaContractual
    WHERE C.IdContrato = @IdContrato;

    /* =========================================================
       determinar si contrato es CIEP
       ========================================================= */
    DECLARE @EsCIEP BIT = 0;

    IF EXISTS (
        SELECT 1
        FROM CO_Contrato C2 WITH (NOLOCK)
        INNER JOIN CO_TipoContrato TC WITH (NOLOCK)
            ON C2.IdTipoContrato = TC.IdTipoContrato
        WHERE C2.IdContrato = @IdContrato
          AND TC.TipoContratoCorto = 'CIEP'
    )
    BEGIN
        SET @EsCIEP = 1;
    END

    /* =========================================================
       Cartas procura
       ========================================================= */
    INSERT INTO #CartasProcura (IdFacutraP, UUID, IdFactura)
    SELECT DISTINCT
        FP.IdFactura,
        FP.UUID,
        FA.IdFactura
    FROM Petrovendor.dbo.MM_AceptacionCartaPCN AS AC (NOLOCK)
    INNER JOIN Petrovendor.dbo.MM_AceptacionPedido AS AP (NOLOCK)
        ON AP.IdAceptacionPedido = AC.IdAceptacionPedido
    INNER JOIN Petrovendor.dbo.MM_Pedido AS P (NOLOCK)
        ON P.IdPedido = AP.IdPedido
       AND P.IdContrato = @IdContrato
       AND AC.IdEstatus = 2
       AND ISNULL(AC.IdEstatusEliminado, 0) <> 1
    LEFT JOIN Petrovendor.dbo.MM_AceptacionFactura as AF (NOLOCK)
        ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
    LEFT JOIN Petrovendor.dbo.FI_Factura as FP (NOLOCK)
        ON FP.IdFactura = AF.IdFactura
    LEFT JOIN Adinco.dbo.FI_Factura as FA (NOLOCK)
        ON FP.UUID = FA.UUID COLLATE DATABASE_DEFAULT
    WHERE AC.IdEstatus = 2
      AND ISNULL(AC.IdEstatusEliminado, 0) <> 1
      AND P.IdContrato = @IdContrato
      AND FP.UUID IS NOT NULL
      AND FP.Activa = 1
      AND ISNULL(FP.IsEliminado, 0) <> 1;

    /* =========================================================
       Validación día 6 del siguiente mes (issue 1891)
       ========================================================= */
    INSERT INTO #MesesAnio (PrimerDiaMes, UltimoDiaMes)
    SELECT DISTINCT
        PrimerDiaMes,
        UltimoDiaMes
    FROM AP_Calendario (NOLOCK)
    WHERE IdFecha = @FechaMes
    ORDER BY UltimoDiaMes DESC;

    UPDATE #MesesAnio
    SET SiguienteMesSeis = DATEFROMPARTS(
        YEAR(DATEADD(MONTH, 1, PrimerDiaMes)),
        MONTH(DATEADD(MONTH, 1, PrimerDiaMes)),
        6
    );

    DELETE FROM #MesesAnio
    WHERE SiguienteMesSeis > @DiaActual;

    IF ((SELECT COUNT(1) FROM #MesesAnio) > 0)
    BEGIN
        SELECT
            @FechaInicio = MIN(PrimerDiaMes),
            @FechaFin    = MAX(UltimoDiaMes)
        FROM #MesesAnio;

        /* =========================================================================
           Solo CIEP:
           - armar meses requeridos según FechaDocumento (mes doc y mes anterior)
           - cargar #TCMensual desde CO_TipoCambioMensual (IdMoneda=1)
           - si el mes anterior al actual está incompleto / ObtenidoSDK=0, generar y refrescar
           ========================================================================= */
        IF (@EsCIEP = 1)
        BEGIN
            CREATE TABLE #TCMensualReq
            (
                AnioTC INT NOT NULL,
                MesTC  INT NOT NULL,
                CONSTRAINT PK_TCMensualReq PRIMARY KEY (AnioTC, MesTC)
            );

            ;WITH BaseFechas AS
            (
                SELECT DISTINCT
                    CASE
                        WHEN R.CvTipoDocFacturacion = 1 THEN CAST(F.Fecha AS DATE)
                        WHEN R.CvTipoDocFacturacion IN (2,3) THEN CAST(PC.FechaPago AS DATE)
                        ELSE NULL
                    END AS FechaDoc
                FROM dbo.CO_PeriodoContrato PEC (NOLOCK)
                LEFT JOIN dbo.CO_ProgramaActividad PA (NOLOCK)
                    ON PEC.IdPeriodo = PA.IdPeriodoContrato
                   AND PEC.IdContrato = @IdContrato
                LEFT JOIN dbo.CO_Presupuesto P (NOLOCK)
                    ON PA.IdProgramaActividad = P.IdProgramaActividad
                LEFT JOIN dbo.CO_LineaPresupuestoMes LPM (NOLOCK)
                    ON P.IdPresupuesto = LPM.IdPresupuesto
                LEFT JOIN dbo.CO_Registro R (NOLOCK)
                    ON R.IdPrograma = LPM.IdLineaPresupuestoMes
                LEFT JOIN dbo.FI_Factura F (NOLOCK)
                    ON F.IdFactura = R.IdFactura
                LEFT JOIN dbo.FI_PedimentoComprobante PC (NOLOCK)
                    ON PC.IdPedimentoComprobante = R.IdPedimentoComprobante
                WHERE PEC.IdContrato = @IdContrato
                  AND R.IdRegistro IS NOT NULL
                  AND (R.MesPresentacion BETWEEN CAST(@FechaInicio AS DATE) AND CAST(@FechaFin AS DATE))
                  AND (
                        (R.CvTipoDocFacturacion = 1 AND F.Fecha IS NOT NULL)
                     OR (R.CvTipoDocFacturacion IN (2,3) AND PC.FechaPago IS NOT NULL)
                  )
            )
            INSERT INTO #TCMensualReq (AnioTC, MesTC)
            SELECT DISTINCT YEAR(FechaDoc), MONTH(FechaDoc)
            FROM BaseFechas
            WHERE FechaDoc IS NOT NULL
            UNION
            SELECT DISTINCT
                YEAR(DATEADD(MONTH,-1, DATEFROMPARTS(YEAR(FechaDoc), MONTH(FechaDoc), 1))),
                MONTH(DATEADD(MONTH,-1, DATEFROMPARTS(YEAR(FechaDoc), MONTH(FechaDoc), 1)))
            FROM BaseFechas
            WHERE FechaDoc IS NOT NULL;

            INSERT INTO #TCMensual (AnioTC, MesTC, TipoCambio, ObtenidoSDK)
            SELECT
                RQ.AnioTC,
                RQ.MesTC,
                TCM.TipoCambio,
                ISNULL(TCM.ObtenidoSDK, 0) AS ObtenidoSDK
            FROM #TCMensualReq RQ
            LEFT JOIN dbo.CO_TipoCambioMensual TCM WITH (NOLOCK)
                ON TCM.IdMoneda = 1
               AND RQ.AnioTC = TCM.Anio
               AND RQ.MesTC  = TCM.IdMes
               AND ISNULL(TCM.Activo, 1) = 1;

            DECLARE @Prev DATE = DATEADD(MONTH, -1, CAST(GETDATE() AS DATE));
            DECLARE @PrevAnio INT = YEAR(@Prev);
            DECLARE @PrevMes  INT = MONTH(@Prev);

            IF EXISTS (
                SELECT 1
                FROM #TCMensual
                WHERE (TipoCambio IS NULL OR TipoCambio = 0 OR ObtenidoSDK = 0)
                  AND AnioTC = @PrevAnio
                  AND MesTC  = @PrevMes
            )
            BEGIN
                EXEC dbo.GenerarPromedioMensualTipoDeCambio;

                UPDATE T
                SET
                    T.TipoCambio  = M.TipoCambio,
                    T.ObtenidoSDK = ISNULL(M.ObtenidoSDK, 0)
                FROM #TCMensual T
                LEFT JOIN dbo.CO_TipoCambioMensual M WITH (NOLOCK)
                    ON M.IdMoneda = 1
                   AND M.Anio     = T.AnioTC
                   AND M.IdMes    = T.MesTC
                   AND ISNULL(M.Activo, 1) = 1
                WHERE T.AnioTC = @PrevAnio
                  AND T.MesTC  = @PrevMes;
            END
        END

        /* =========================================================
           INSERT principal (con switch CIEP mensual / no CIEP diario)
           ========================================================= */
        INSERT INTO #Datos
        (
            IdRegistro,
            Servicio,
            InstalacionPresupuestada,
            FechaInicio,
            FechaFin,
            TipoDocumento,
            Numero,
            FechaDocumento,
            MontoUSD,
            TipoCambioUsado,
            UsaTCMesAnterior,
            Subcontratista,
            InstalacionRegistro,
            InicioEjecucion,
            FinEjecucion,
            CreadoPor,
            MontoRegistro,
            Moneda,
            MesPresentacion,
            Anio,
            Mes,
            TipoDeServicio,
            Actividad,
            SubActividad,
            EstadoValidacion,
            Area,
            Comentarios,
            Anexo4,
            Identificador,
            LineaPresupuesto,
            Presupuesto,
            Rubro,
            CatManoObra,
            PCN,
            CAA,
            CCN,
            ModificadoPor
        )
        SELECT
            R.IdRegistro,
            S.NombreServicio AS Servicio,
            F.UUID,
            LPM.AC_FEC_INI AS FechaInicio,
            LPM.AC_FEC_FIN AS FechaFin,
            CASE
                WHEN R.CvTipoDocFacturacion = 1 THEN 'CF'
                WHEN R.CvTipoDocFacturacion = 2 THEN 'PI'
                WHEN R.CvTipoDocFacturacion = 3 THEN 'PE'
            END AS TipoDocumento,
            CASE
                WHEN R.CvTipoDocFacturacion = 1 THEN LTRIM(RTRIM(F.Serie + ' ' + F.Folio))
                WHEN R.CvTipoDocFacturacion = 2 THEN PC.NumeroPedimento
                WHEN R.CvTipoDocFacturacion = 3 THEN PC.FolioComprobante
            END AS Numero,
            CASE
                WHEN R.CvTipoDocFacturacion = 1 THEN F.Fecha
                WHEN R.CvTipoDocFacturacion IN (2,3) THEN PC.FechaPago
            END AS FechaDocumento,

            /* ==========================
               MontoUSD
               ========================== */
            CASE
                WHEN R.CvTipoDocFacturacion = 1 THEN
                    SUM(
                        CASE
                            WHEN ISNULL(R.MontoRegistro,0) <> 0 THEN
                                ISNULL(R.MontoRegistro,0) / NULLIF(
                                    CASE
                                        WHEN TMF.IdMoneda = 2 THEN 1
                                        WHEN @EsCIEP = 1 AND TMF.IdMoneda = 1 THEN
                                            COALESCE(NULLIF(TCM_DOC.TipoCambio,0), NULLIF(TCM_PREV.TipoCambio,0))
                                        ELSE
                                            TCDF.TipoCambio
                                    END
                                ,0)
                            ELSE 0
                        END
                    )
                WHEN R.CvTipoDocFacturacion IN (2,3) THEN
                    SUM(
                        CASE
                            WHEN ISNULL(R.MontoRegistro,0) <> 0 THEN
                                ISNULL(R.MontoRegistro,0) / NULLIF(
                                    CASE
                                        WHEN TMPC.IdMoneda = 2 THEN 1
                                        WHEN @EsCIEP = 1 AND TMPC.IdMoneda = 1 THEN
                                            COALESCE(NULLIF(TCM_DOC.TipoCambio,0), NULLIF(TCM_PREV.TipoCambio,0))
                                        ELSE
                                            TCDPC.TipoCambio
                                    END
                                ,0)
                            ELSE 0
                        END
                    )
            END AS MontoUSD,

            /* ==========================
               TipoCambioUsado
               ========================== */
            CASE
                WHEN R.CvTipoDocFacturacion = 1 THEN
                    CAST(
                        CASE
                            WHEN TMF.IdMoneda = 2 THEN 1
                            WHEN @EsCIEP = 1 AND TMF.IdMoneda = 1 THEN
                                COALESCE(NULLIF(TCM_DOC.TipoCambio,0), NULLIF(TCM_PREV.TipoCambio,0))
                            ELSE
                                TCDF.TipoCambio
                        END AS DECIMAL(18,6)
                    )
                WHEN R.CvTipoDocFacturacion IN (2,3) THEN
                    CAST(
                        CASE
                            WHEN TMPC.IdMoneda = 2 THEN 1
                            WHEN @EsCIEP = 1 AND TMPC.IdMoneda = 1 THEN
                                COALESCE(NULLIF(TCM_DOC.TipoCambio,0), NULLIF(TCM_PREV.TipoCambio,0))
                            ELSE
                                TCDPC.TipoCambio
                        END AS DECIMAL(18,6)
                    )
            END AS TipoCambioUsado,

            /* ==========================
               UsaTCMesAnterior
               ========================== */
            ISNULL(
                CASE
                    WHEN R.CvTipoDocFacturacion = 1 THEN
                        CASE
                            WHEN @EsCIEP = 1 AND TMF.IdMoneda = 1
                                 AND (TCM_DOC.TipoCambio IS NULL OR TCM_DOC.TipoCambio = 0)
                                 AND (TCM_PREV.TipoCambio IS NOT NULL AND TCM_PREV.TipoCambio <> 0)
                                THEN 1
                            ELSE 0
                        END
                    WHEN R.CvTipoDocFacturacion IN (2,3) THEN
                        CASE
                            WHEN @EsCIEP = 1 AND TMPC.IdMoneda = 1
                                 AND (TCM_DOC.TipoCambio IS NULL OR TCM_DOC.TipoCambio = 0)
                                 AND (TCM_PREV.TipoCambio IS NOT NULL AND TCM_PREV.TipoCambio <> 0)
                                THEN 1
                            ELSE 0
                        END
                    ELSE 0
                END
            ,0) AS UsaTCMesAnterior,

            CASE
                WHEN R.CvTipoDocFacturacion = 1 THEN SF.RazonSocial
                WHEN R.CvTipoDocFacturacion IN (2,3) THEN SPC.RazonSocial
            END AS Subcontratista,
            IR.NombreInstalacion AS InstalacionRegistro,
            R.InicioEjecucion,
            R.FinEjecucion,
            U.Nombre AS CreadoPor,
            R.MontoRegistro,
            CASE
                WHEN R.CvTipoDocFacturacion = 1 THEN TMF.TipoMonedaCorto
                WHEN R.CvTipoDocFacturacion IN (2,3) THEN TMPC.TipoMonedaCorto
            END AS Moneda,
            R.MesPresentacion AS MesPresentacion,
            YEAR(R.MesPresentacion) AS Anio,
            CONCAT(RIGHT('00' + CAST(MONTH(R.MesPresentacion) AS VARCHAR(2)), 2), ' ', DATENAME(MONTH, R.MesPresentacion)) AS Mes,
            CASE WHEN P.CIEP = 1 THEN TS.NombreTipoServicio ELSE ACNH.DescripcionActividadPetrolera END AS TipoDeServicio,
            CASE WHEN P.CIEP = 1 THEN ACIEP.NombreActividad ELSE SAP.SubactividadPetrolera END AS Actividad,
            CASE WHEN P.CIEP = 1 THEN RI.NombreRubro ELSE TP.TareaPetrolera END AS SubActividad,
            CAST(
                CASE
                    WHEN @NombreAreaContractual = 'Amatitlán' THEN @NombreEstadoInicialAmatitlan
                    ELSE ER.NombreEstado
                END AS VARCHAR(100)
            ) AS EstadoValidacion,
            A.NombreArea AS Area,
            R.Comentarios,
            CA.ClasificacionAnexo4 AS Anexo4,
            CASE
                WHEN R.CvTipoDocFacturacion = 1 THEN F.IdFactura
                WHEN R.CvTipoDocFacturacion IN (2,3) THEN PC.IdPedimentoComprobante
            END AS Identificador,
            LPM.IdLineaPresupuestoMes AS LineaPresupuesto,
            P.Nombre AS Presupuesto,
            rubro.Descripcion AS Rubro,
            catmo.Nombre AS CatManoObra,
            R.PCN,
            CASE WHEN R.CostosAtribuiblesAdministracion = 1 THEN 'SI' ELSE 'NO' END AS CAA,
            CASE
                WHEN WA.IdDocAwsDocAdinco IS NULL AND R.CvTipoDocFacturacion = 1 THEN 'NO'
                WHEN WA.IdDocAwsDocAdinco IS NULL AND R.CvTipoDocFacturacion IN (2,3) THEN 'NA'
                ELSE 'SI'
            END AS CCN,
            UM.Nombre AS ModificadoPor
        FROM dbo.CO_PeriodoContrato PEC (NOLOCK)
        LEFT JOIN dbo.CO_ProgramaActividad PA (NOLOCK)
            ON PEC.IdPeriodo = PA.IdPeriodoContrato
           AND PEC.IdContrato = @IdContrato
        LEFT JOIN dbo.CO_Presupuesto P (NOLOCK)
            ON PA.IdProgramaActividad = P.IdProgramaActividad
        LEFT JOIN dbo.CO_LineaPresupuestoMes LPM (NOLOCK)
            ON P.IdPresupuesto = LPM.IdPresupuesto
        LEFT JOIN dbo.CO_Servicio S (NOLOCK)
            ON LPM.IdServicio = S.IdServicio
        LEFT JOIN dbo.CO_Registro R (NOLOCK)
            ON R.IdPrograma = LPM.IdLineaPresupuestoMes
        LEFT JOIN dbo.CO_GastosRubro rubro (NOLOCK)
            ON rubro.IdGastoRubro = R.IdGastoRubro
        LEFT JOIN dbo.CO_CAT_ManoDeObra catmo (NOLOCK)
            ON catmo.Id = R.IdCatManoObra
        LEFT JOIN dbo.FI_Factura F (NOLOCK)
            ON F.IdFactura = R.IdFactura
        LEFT JOIN dbo.FI_PedimentoComprobante PC (NOLOCK)
            ON PC.IdPedimentoComprobante = R.IdPedimentoComprobante

        /* ============================================================
           FechaDoc y llaves para TC mensual (CIEP)
           ============================================================ */
        OUTER APPLY (
            SELECT
                CASE
                    WHEN R.CvTipoDocFacturacion = 1 THEN CAST(F.Fecha AS DATE)
                    WHEN R.CvTipoDocFacturacion IN (2,3) THEN CAST(PC.FechaPago AS DATE)
                    ELSE NULL
                END AS FechaDoc
        ) FD
        OUTER APPLY (
            SELECT
                YEAR(FD.FechaDoc) AS AnioDoc,
                MONTH(FD.FechaDoc) AS MesDoc,
                YEAR(DATEADD(MONTH, -1, DATEFROMPARTS(YEAR(FD.FechaDoc), MONTH(FD.FechaDoc), 1))) AS AnioPrev,
                MONTH(DATEADD(MONTH, -1, DATEFROMPARTS(YEAR(FD.FechaDoc), MONTH(FD.FechaDoc), 1))) AS MesPrev
            WHERE FD.FechaDoc IS NOT NULL
        ) CTC
        LEFT JOIN #TCMensual TCM_DOC
            ON @EsCIEP = 1
           AND CTC.AnioDoc = TCM_DOC.AnioTC
           AND CTC.MesDoc  = TCM_DOC.MesTC
        LEFT JOIN #TCMensual TCM_PREV
            ON @EsCIEP = 1
           AND CTC.AnioPrev = TCM_PREV.AnioTC
           AND CTC.MesPrev  = TCM_PREV.MesTC

        LEFT JOIN dbo.PV_Subcontratista SF (NOLOCK)
            ON F.IdSubcontratista = SF.IdSubcontratista
        LEFT JOIN dbo.PV_Subcontratista SPC (NOLOCK)
            ON SPC.IdSubcontratista = PC.IdSubcontratistaExportador
        LEFT JOIN dbo.CO_Instalacion IR (NOLOCK)
            ON R.IdInstalacion = IR.IdInstalacion
        LEFT JOIN dbo.AP_Usuario U (NOLOCK)
            ON R.IdUsuarioCreadoPor = U.UsuarioID
        LEFT JOIN dbo.CO_TipoServicio TS (NOLOCK)
            ON LPM.IdTipoServicio = TS.IdTipoServicio
        LEFT JOIN dbo.CO_ActividadCIEP ACIEP (NOLOCK)
            ON LPM.IdActividad = ACIEP.IdActividad
        LEFT JOIN dbo.CO_SubactividadCIEP SCIEP (NOLOCK)
            ON LPM.IdSubactividad = SCIEP.IdSubactividad
        LEFT JOIN dbo.CO_EstadoRegistro ER (NOLOCK)
            ON R.IdEstado = ER.IdEstadoRegistro
        LEFT JOIN dbo.CO_Area A (NOLOCK)
            ON A.IdArea = LPM.IdArea

        LEFT JOIN dbo.PV_TipoMoneda TMF (NOLOCK)
            ON TMF.IdMoneda = F.IdMoneda
        LEFT JOIN dbo.CO_TipoCambioDiario TCDF (NOLOCK)
            ON TCDF.IdMoneda = TMF.IdMoneda
           AND DAY(TCDF.Fecha) = DAY(F.Fecha)
           AND MONTH(TCDF.Fecha) = MONTH(F.Fecha)
           AND YEAR(TCDF.Fecha) = YEAR(F.Fecha)

        LEFT JOIN dbo.PV_TipoMoneda TMPC (NOLOCK)
            ON TMPC.IdMoneda = PC.IdMoneda
        LEFT JOIN dbo.CO_TipoCambioDiario TCDPC (NOLOCK)
            ON TCDPC.IdMoneda = TMPC.IdMoneda
           AND DAY(TCDPC.Fecha) = DAY(PC.FechaPago)
           AND MONTH(TCDPC.Fecha) = MONTH(PC.FechaPago)
           AND YEAR(TCDPC.Fecha) = YEAR(PC.FechaPago)

        LEFT JOIN dbo.CO_ClasificacionAnexo4 CA (NOLOCK)
            ON LPM.IdAnexo4 = CA.IdAnexo4
        LEFT JOIN dbo.CO_ActividadPetroleraCNH ACNH (NOLOCK)
            ON LPM.IdActividadPetrolera = ACNH.IdActividadPetrolera
        LEFT JOIN dbo.CO_SubactividadPetrolera SAP (NOLOCK)
            ON LPM.IdSubactividadPetrolera = SAP.IdSubactividadPetrolera
        LEFT JOIN dbo.CO_RubroInterno RI (NOLOCK)
            ON LPM.IdRubroInterno = RI.IdRubroInterno
        LEFT JOIN dbo.CO_TareaPetrolera TP (NOLOCK)
            ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera
        LEFT JOIN dbo.AWS_DocAwsDocAdinco WA (NOLOCK)
            ON F.IdFactura = WA.IdDocAdinco
        LEFT JOIN dbo.AP_Usuario UM (NOLOCK)
            ON R.IdUsuarioModPor = UM.UsuarioID
        WHERE PEC.IdContrato = @IdContrato
          AND R.IdRegistro IS NOT NULL
          AND (R.MesPresentacion BETWEEN CAST(@FechaInicio AS DATE) AND CAST(@FechaFin AS DATE))
        GROUP BY
            PC.NumeroPedimento,
            S.NombreServicio,
            F.UUID,
            LPM.AC_FEC_INI,
            LPM.AC_FEC_FIN,
            F.Fecha,
            LTRIM(RTRIM(F.Serie + ' ' + F.Folio)),
            SF.RazonSocial,
            IR.NombreInstalacion,
            R.InicioEjecucion,
            R.FinEjecucion,
            U.Nombre,
            R.MontoRegistro,
            TMF.TipoMonedaCorto,
            TMF.IdMoneda,
            TCDF.TipoCambio,
            TMPC.TipoMonedaCorto,
            TMPC.IdMoneda,
            TCDPC.TipoCambio,
            TCM_DOC.TipoCambio,
            TCM_PREV.TipoCambio,
            YEAR(R.MesPresentacion),
            CONCAT(RIGHT('00' + CAST(MONTH(R.MesPresentacion) AS VARCHAR(2)), 2), ' ', DATENAME(MONTH, R.MesPresentacion)),
            R.MesPresentacion,
            CASE WHEN P.CIEP = 1 THEN TS.NombreTipoServicio ELSE ACNH.DescripcionActividadPetrolera END,
            CASE WHEN P.CIEP = 1 THEN ACIEP.NombreActividad ELSE SAP.SubactividadPetrolera END,
            CASE WHEN P.CIEP = 1 THEN RI.NombreRubro ELSE TP.TareaPetrolera END,
            R.IdRegistro,
            ER.NombreEstado,
            A.NombreArea,
            R.Comentarios,
            CA.ClasificacionAnexo4,
            F.IdFactura,
            PC.IdPedimentoComprobante,
            IR.CUIP,
            IR.WelIID,
            LPM.IdLineaPresupuestoMes,
            IR.IdInstalacion,
            P.Nombre,
            R.CvTipoDocFacturacion,
            PC.FechaPago,
            PC.IdMoneda,
            PC.FolioComprobante,
            SPC.RazonSocial,
            rubro.Descripcion,
            catmo.Nombre,
            R.PCN,
            CASE WHEN R.CostosAtribuiblesAdministracion = 1 THEN 'SI' ELSE 'NO' END,
            CASE
                WHEN WA.IdDocAwsDocAdinco IS NULL AND R.CvTipoDocFacturacion = 1 THEN 'NO'
                WHEN WA.IdDocAwsDocAdinco IS NULL AND R.CvTipoDocFacturacion IN (2,3) THEN 'NA'
                ELSE 'SI'
            END,
            UM.Nombre
        ORDER BY R.IdRegistro DESC;

        UPDATE #Datos
        SET #Datos.CCN = 'SI'
        FROM #Datos D
        JOIN #CartasProcura CP
            ON D.Identificador = CP.IdFactura
        WHERE D.Identificador = CP.IdFactura
          AND D.TipoDocumento = 'CF';
    END

    IF (@NombreAreaContractual = 'Amatitlán')
    BEGIN
        UPDATE #Datos
        SET #Datos.EstadoValidacion = CO_EstadoRegistro_V2.NombreEstado
        FROM #Datos
        JOIN CO_RegistroMarkup
            ON #Datos.IdRegistro = CO_RegistroMarkup.GastoId
           AND CO_RegistroMarkup.IdEstadoPemex IS NOT NULL
        JOIN CO_EstadoRegistro_V2
            ON CO_EstadoRegistro_V2.Idcontrato = 10007
           AND CO_RegistroMarkup.IdEstadoPemex = CO_EstadoRegistro_V2.IdClvEstado;
    END

    SELECT
        d.IdRegistro,
        d.Servicio,
        d.InstalacionPresupuestada,
        d.FechaInicio,
        d.FechaFin,
        d.TipoDocumento,
        d.Numero,
        d.FechaDocumento,
        d.MontoUSD,
        d.TipoCambioUsado,
        d.UsaTCMesAnterior,
        d.Subcontratista,
        d.InstalacionRegistro,
        d.InicioEjecucion,
        d.FinEjecucion,
        d.CreadoPor,
        d.MontoRegistro,
        d.Moneda,
        d.MesPresentacion,
        d.Anio,
        d.Mes,
        d.TipoDeServicio,
        d.Actividad,
        d.SubActividad,
        d.EstadoValidacion,
        d.Area,
        d.Comentarios,
        d.Anexo4,
        d.Identificador,
        d.LineaPresupuesto,
        d.Presupuesto,
        d.Rubro,
        d.CatManoObra,
        d.PCN,
        d.CAA,
        d.CCN,
        d.ModificadoPor
    FROM #Datos d;
END
GO
