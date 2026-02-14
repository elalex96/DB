IF EXISTS (
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_CO_ConsultaRegistrosGastos'
)
    DROP PROCEDURE sp_CO_ConsultaRegistrosGastos;
GO

CREATE PROCEDURE [dbo].[sp_CO_ConsultaRegistrosGastos]
    @IdPresupuesto INT
AS
BEGIN
    SET NOCOUNT ON;
    SET LANGUAGE spanish;

    -------------------------------------------------------------------------
    -- TABLA TEMP: Cartas Procura
    -- Se usa para marcar CCN = 'SI' cuando el registro tiene carta de procura
    -------------------------------------------------------------------------
    CREATE TABLE #CartasProcura
    (
        IdFacutraP INT,
        UUID       VARCHAR(100),
        IdFactura  INT
    );

    -------------------------------------------------------------------------
    -- TABLA TEMP: Datos del grid final
    --   - TipoCambioUsado: TC que realmente se aplicó para convertir el monto a USD
    --   - UsaTCMesAnterior: bandera (solo CIEP + Moneda=1) indicando que NO hubo TC mensual del mes
    --     y se usó el TC del mes anterior.
    -------------------------------------------------------------------------
    CREATE TABLE #Datos
    (
        IdRegistro               INT,
        Servicio                 VARCHAR(1000),
        InstalacionPresupuestada VARCHAR(1000),
        FechaInicio              DATE,
        FechaFin                 DATE,
        TipoDocumento            VARCHAR(100),
        Numero                   VARCHAR(500),
        FechaDocumento           DATETIME,
        MontoUSD                 FLOAT,

        /* ============================================================
           - TipoCambioUsado: TC final utilizado (mensual CIEP / diario / 1 cuando es USD)
           ============================================================ */
        TipoCambioUsado          DECIMAL(18,6) NULL,

        /* ============================================================
           1 = (CIEP + Moneda=1) NO existe TC mensual del mismo mes, y se usa el del mes anterior
           0 = cualquier otro caso
           ============================================================ */
        UsaTCMesAnterior         BIT NULL,

        Subcontratista           VARCHAR(1000),
        InstalacionRegistro      VARCHAR(500),
        InicioEjecucion          DATE,
        FinEjecucion             DATE,
        CreadoPor                VARCHAR(500),
        MontoRegistro            FLOAT,
        Moneda                   VARCHAR(50),
        MesPresentacion          DATE,
        Anio                     INT,
        Mes                      VARCHAR(500),
        TipoDeServicio           VARCHAR(500),
        Actividad                VARCHAR(1000),
        SubActividad             VARCHAR(1000),
        EstadoValidacion         VARCHAR(500),
        Area                     VARCHAR(500),
        Comentarios              VARCHAR(5000),
        Anexo4                   VARCHAR(500),
        Identificador            INT,
        LineaPresupuesto         INT,
        Presupuesto              VARCHAR(1000),
        Rubro                    VARCHAR(500),
        CatManoObra              VARCHAR(500),
        PCN                      FLOAT,
        CAA                      VARCHAR(500),
        CCN                      VARCHAR(500),
        ModificadoPor            VARCHAR(500),
        RegistroConAjuste        BIT NULL,
        AsociadoIncrementoPMT    BIT NULL
    );

    DECLARE
        @Contrato                     INT,
        @NombreAreaContractual        VARCHAR(100) = '',
        @NombreEstadoInicialAmatitlan VARCHAR(100) = 'Revisión';

    -------------------------------------------------------------------------
    -- Resolver contrato a partir del presupuesto
    -------------------------------------------------------------------------
    SELECT
        @Contrato = PC.IdContrato
    FROM dbo.CO_Presupuesto P (NOLOCK)
    JOIN dbo.CO_ProgramaActividad PA (NOLOCK)
        ON PA.IdProgramaActividad = P.IdProgramaActividad
    JOIN dbo.CO_PeriodoContrato PC (NOLOCK)
        ON PC.IdPeriodo = PA.IdPeriodoContrato
    WHERE ((P.IdPresupuesto = @IdPresupuesto) OR @IdPresupuesto = -1);

    SELECT TOP 1
        @NombreAreaContractual = ISNULL(AC.NombreAreaContractual, '')
    FROM CO_Contrato C (NOLOCK)
    JOIN CO_AreaContractual AC (NOLOCK)
        ON C.IdAreaContractual = AC.IdAreaContractual
    WHERE C.IdContrato = @Contrato;

    -------------------------------------------------------------------------
    -- Determinar si el contrato es CIEP
    -------------------------------------------------------------------------
    DECLARE @EsCIEP BIT = 0;

    IF EXISTS (
        SELECT 1
        FROM CO_Contrato C2 WITH (NOLOCK)
        INNER JOIN CO_TipoContrato TC WITH (NOLOCK)
            ON C2.IdTipoContrato = TC.IdTipoContrato
        WHERE C2.IdContrato = @Contrato
          AND TC.TipoContratoCorto = 'CIEP'
    )
    BEGIN
        SET @EsCIEP = 1;
    END

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

    /* =========================================================================
       - Solo si es CIEP, armamos la lista de meses requeridos (mes del documento y mes anterior)
       - Se carga #TCMensual con CO_TipoCambioMensual (IdMoneda = 1)
       - Si el mes anterior al actual está incompleto o no fue obtenido por SDK (ObtenidoSDK=0),
         se ejecuta GenerarPromedioMensualTipoDeCambio y se refresca ese mes.
       ========================================================================= */
    IF (@EsCIEP = 1)
    BEGIN
        CREATE TABLE #TCMensualReq
        (
            AnioTC INT NOT NULL,
            MesTC  INT NOT NULL,
            CONSTRAINT PK_TCMensualReq PRIMARY KEY (AnioTC, MesTC)
        );

        ;WITH BaseFechas AS (
            SELECT DISTINCT
                CASE
                    WHEN R.CvTipoDocFacturacion = 1 THEN CAST(F.Fecha AS DATE)
                    WHEN R.CvTipoDocFacturacion IN (2,3) THEN CAST(PC.FechaPago AS DATE)
                    ELSE NULL
                END AS FechaDoc
            FROM dbo.CO_LineaPresupuestoMes LPM (NOLOCK)
            JOIN dbo.CO_Presupuesto P (NOLOCK)
                ON LPM.IdPresupuesto = P.IdPresupuesto
               AND (P.IdPresupuesto = @IdPresupuesto OR @IdPresupuesto = -1)
            JOIN dbo.CO_Registro R (NOLOCK)
                ON LPM.IdLineaPresupuestoMes = R.IdPrograma
            LEFT JOIN dbo.FI_Factura F (NOLOCK)
                ON R.IdFactura = F.IdFactura
            LEFT JOIN dbo.FI_PedimentoComprobante PC (NOLOCK)
                ON R.IdPedimentoComprobante = PC.IdPedimentoComprobante
            WHERE R.IdRegistro IS NOT NULL
              AND (
                    (R.CvTipoDocFacturacion = 1 AND F.Fecha IS NOT NULL)
                 OR (R.CvTipoDocFacturacion IN (2,3) AND PC.FechaPago IS NOT NULL)
              )
        )
        INSERT INTO #TCMensualReq (AnioTC, MesTC)
        SELECT DISTINCT YEAR(FechaDoc), MONTH(FechaDoc)
        FROM BaseFechas
        UNION
        SELECT DISTINCT
            YEAR(DATEADD(MONTH,-1, DATEFROMPARTS(YEAR(FechaDoc), MONTH(FechaDoc), 1))),
            MONTH(DATEADD(MONTH,-1, DATEFROMPARTS(YEAR(FechaDoc), MONTH(FechaDoc), 1)))
        FROM BaseFechas;

        INSERT INTO #TCMensual (AnioTC, MesTC, TipoCambio, ObtenidoSDK)
        SELECT
            RQ.AnioTC,
            RQ.MesTC,
            TCM.TipoCambio,
            ISNULL(TCM.ObtenidoSDK, 0) AS ObtenidoSDK
        FROM #TCMensualReq RQ
        LEFT JOIN dbo.CO_TipoCambioMensual TCM WITH (NOLOCK)
            ON TCM.IdMoneda = 1
           AND TCM.Anio = RQ.AnioTC
           AND TCM.IdMes = RQ.MesTC
           AND ISNULL(TCM.Activo, 1) = 1;

        DECLARE @Prev DATE = DATEADD(MONTH, -1, CAST(GETDATE() AS DATE));
        DECLARE @PrevAnio INT = YEAR(@Prev);
        DECLARE @PrevMes  INT = MONTH(@Prev);

        IF EXISTS (
            SELECT 1
            FROM #TCMensual
            WHERE (TipoCambio IS NULL OR TipoCambio = 0 OR ObtenidoSDK = 0)
              AND AnioTC = @PrevAnio
              AND MesTC = @PrevMes
        )
        BEGIN
            EXEC dbo.GenerarPromedioMensualTipoDeCambio;

            UPDATE T
            SET
                T.TipoCambio = M.TipoCambio,
                T.ObtenidoSDK = ISNULL(M.ObtenidoSDK, 0)
            FROM #TCMensual T
            LEFT JOIN dbo.CO_TipoCambioMensual M WITH (NOLOCK)
                ON M.IdMoneda = 1
               AND M.Anio = T.AnioTC
               AND M.IdMes = T.MesTC
               AND ISNULL(M.Activo, 1) = 1
            WHERE T.AnioTC = @PrevAnio
              AND T.MesTC = @PrevMes;
        END
    END

    ---------------------------------------------------------------------
    -- Cartas procura (Factura)
    ---------------------------------------------------------------------
    INSERT INTO #CartasProcura (IdFacutraP, UUID, IdFactura)
    SELECT DISTINCT
        FP.IdFactura,
        FP.UUID,
        FA.IdFactura
    FROM Petrovendor.dbo.MM_Pedido AS P (NOLOCK)
    JOIN Petrovendor.dbo.MM_AceptacionPedido AS AP (NOLOCK)
        ON P.IdPedido = AP.IdPedido
       AND P.IdContrato = @Contrato
    JOIN Petrovendor.dbo.MM_AceptacionCartaPCN AS AC (NOLOCK)
        ON AP.IdAceptacionPedido = AC.IdAceptacionPedido
    JOIN Petrovendor.dbo.S_Documento_S3 AS D (NOLOCK)
        ON AC.IdDocumento = D.IdDocumento
       AND AC.IdEstatus = 2
       AND ISNULL(AC.IdEstatusEliminado, 0) <> 1
    JOIN Petrovendor.dbo.S_Proveedor AS PR (NOLOCK)
        ON P.IdSubcontratista = PR.IdProveedor
    JOIN Petrovendor.dbo.S_TipoValidacionDoc AS TD (NOLOCK)
        ON AC.IdEstatus = TD.IdTipoValidacionDoc
    JOIN Petrovendor.dbo.MM_Pedidos AS PG (NOLOCK)
        ON P.IdPedido = PG.IdIdentificador
    LEFT JOIN Petrovendor.dbo.MM_TipoPedido AS TP (NOLOCK)
        ON PG.IdTipoPedido = TP.IdTipoPedido
    LEFT JOIN Petrovendor.dbo.MM_AceptacionFactura AS AF (NOLOCK)
        ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
    LEFT JOIN Petrovendor.dbo.FI_Factura AS FP (NOLOCK)
        ON AF.IdFactura = FP.IdFactura
       AND FP.Activa = 1
    LEFT JOIN Adinco.dbo.FI_Factura AS FA (NOLOCK)
        ON FP.UUID = FA.UUID COLLATE DATABASE_DEFAULT
    WHERE AC.IdEstatus = 2
      AND ISNULL(AC.IdEstatusEliminado, 0) <> 1
      AND P.IdContrato = @Contrato
      AND FP.UUID IS NOT NULL
      AND FP.Activa = 1
      AND ISNULL(FP.IsEliminado, 0) <> 1;

    ---------------------------------------------------------------------
    -- Cartas procura (Pedimento/Comprobante)
    ---------------------------------------------------------------------
    INSERT INTO #CartasProcura (IdFacutraP, UUID, IdFactura)
    SELECT
        PC.IdPedimentoComprobante,
        '',
        ADPC.IdPedimentoComprobante
    FROM Petrovendor..FI_PedimentoComprobante PC (NOLOCK)
    JOIN Petrovendor..FI_AceptacionPedido_PedimentoComprobante APC (NOLOCK)
        ON PC.IdPedimentoComprobante = APC.IdPedimentoComprobante
       AND PC.IdContrato = @Contrato
       AND PC.IsActivo = 1
    JOIN Petrovendor..FI_RelacionComprobanteAdinco RC (NOLOCK)
        ON PC.IdPedimentoComprobante = RC.IdComprobantePetrovendor
    JOIN Adinco..FI_PedimentoComprobante ADPC (NOLOCK)
        ON RC.IdComprobanteAdinco = ADPC.IdPedimentoComprobante
       AND ADPC.Activo = 1
    JOIN Petrovendor.dbo.MM_AceptacionPedido AS AP (NOLOCK)
        ON APC.IdAceptacionPedido = AP.IdAceptacionPedido
    JOIN Petrovendor.dbo.MM_Pedido P2 (NOLOCK)
        ON AP.IdPedido = P2.IdPedido
       AND P2.IdContrato = @Contrato
    JOIN Petrovendor..RelacionCartaCNPedido RSC (NOLOCK)
        ON AP.IdAceptacionPedido = RSC.IdAceptacionPedido
       AND RSC.PedirCarta = 1
    JOIN Petrovendor.dbo.MM_AceptacionCartaPCN AS AC2 (NOLOCK)
        ON AP.IdAceptacionPedido = AC2.IdAceptacionPedido
       AND AC2.IdEstatus = 2
       AND ISNULL(AC2.IdEstatusEliminado, 0) <> 1
    JOIN Petrovendor.dbo.S_Documento_S3 AS D2 (NOLOCK)
        ON AC2.IdDocumento = D2.IdDocumento
    JOIN Petrovendor.dbo.S_TipoValidacionDoc AS TD2 (NOLOCK)
        ON AC2.IdEstatus = TD2.IdTipoValidacionDoc
    WHERE AC2.IdEstatus = 2
      AND ISNULL(AC2.IdEstatusEliminado, 0) <> 1
      AND ADPC.Activo = 1
      AND PC.IsActivo = 1
    GROUP BY
        PC.IdPedimentoComprobante,
        ADPC.IdPedimentoComprobante;

    ---------------------------------------------------------------------
    -- Datos (INSERT principal)
    --   - Se calcula MontoUSD usando:
    --       * USD (IdMoneda=2) => TC=1
    --       * CIEP + Moneda=1 => TC mensual del mes; si no hay, TC mensual del mes anterior
    --       * Otro caso => TC diario
    --   - Se guarda TipoCambioUsado (para auditoría/visibilidad en el grid)
    --   - Se marca UsaTCMesAnterior = 1 cuando se tomó el TC mensual del mes anterior por falta del mes actual
    ---------------------------------------------------------------------
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
        ModificadoPor,
        RegistroConAjuste,
        AsociadoIncrementoPMT
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
                        WHEN ISNULL(R.MontoRegistro, 0) <> 0 THEN
                            ISNULL(R.MontoRegistro, 0) / NULLIF(
                                CASE
                                    WHEN TMF.IdMoneda = 2 THEN 1
                                    WHEN @EsCIEP = 1 AND TMF.IdMoneda = 1 THEN
                                        COALESCE(NULLIF(TCM_DOC.TipoCambio,0), NULLIF(TCM_PREV.TipoCambio,0))
                                    ELSE TCDF.TipoCambio
                                END
                            , 0)
                        ELSE 0
                    END
                )
            WHEN R.CvTipoDocFacturacion IN (2,3) THEN
                SUM(
                    CASE
                        WHEN ISNULL(R.MontoRegistro, 0) <> 0 THEN
                            ISNULL(R.MontoRegistro, 0) / NULLIF(
                                CASE
                                    WHEN TMPC.IdMoneda = 2 THEN 1
                                    WHEN @EsCIEP = 1 AND TMPC.IdMoneda = 1 THEN
                                        COALESCE(NULLIF(TCM_DOC.TipoCambio,0), NULLIF(TCM_PREV.TipoCambio,0))
                                    ELSE TCDPC.TipoCambio
                                END
                            , 0)
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
                        ELSE TCDF.TipoCambio
                    END AS DECIMAL(18,6)
                )
            WHEN R.CvTipoDocFacturacion IN (2,3) THEN
                CAST(
                    CASE
                        WHEN TMPC.IdMoneda = 2 THEN 1
                        WHEN @EsCIEP = 1 AND TMPC.IdMoneda = 1 THEN
                            COALESCE(NULLIF(TCM_DOC.TipoCambio,0), NULLIF(TCM_PREV.TipoCambio,0))
                        ELSE TCDPC.TipoCambio
                    END AS DECIMAL(18,6)
                )
        END AS TipoCambioUsado,

        /* ==========================
           UsaTCMesAnterior
           - 1 solo cuando:
             * Es CIEP
             * Moneda = 1
             * NO hay TC mensual del mes del documento (NULL/0)
             * SI hay TC mensual del mes anterior (no NULL/0)
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
        , 0) AS UsaTCMesAnterior,

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
        CASE
            WHEN P.CIEP = 1 THEN TS.NombreTipoServicio
            ELSE ACNH.DescripcionActividadPetrolera
        END AS TipoDeServicio,
        CASE
            WHEN P.CIEP = 1 THEN ACIEP.NombreActividad
            ELSE SAP.SubactividadPetrolera
        END AS Actividad,
        CASE
            WHEN P.CIEP = 1 THEN RI.NombreRubro
            ELSE TP.TareaPetrolera
        END AS SubActividad,
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
        CASE
            WHEN R.CostosAtribuiblesAdministracion = 1 THEN 'SI'
            ELSE 'NO'
        END AS CAA,
        CASE
            WHEN WA.IdDocAwsDocAdinco IS NULL AND R.CvTipoDocFacturacion = 1 THEN 'NO'
            WHEN WA.IdDocAwsDocAdinco IS NULL AND R.CvTipoDocFacturacion IN (2,3) THEN 'NA'
            ELSE 'SI'
        END AS CCN,
        UM.Nombre AS ModificadoPor,
        ISNULL(R.RegistroConAjuste, 0) AS RegistroConAjuste,
        ISNULL(R.AsociadoIncrementoPMT, 0) AS AsociadoIncrementoPMT
    FROM dbo.CO_LineaPresupuestoMes LPM (NOLOCK)
    JOIN dbo.CO_Presupuesto P (NOLOCK)
        ON LPM.IdPresupuesto = P.IdPresupuesto
       AND (P.IdPresupuesto = @IdPresupuesto OR @IdPresupuesto = -1)
    JOIN dbo.CO_Registro R (NOLOCK)
        ON LPM.IdLineaPresupuestoMes = R.IdPrograma
    LEFT JOIN dbo.CO_Servicio S (NOLOCK)
        ON LPM.IdServicio = S.IdServicio
    LEFT JOIN dbo.CO_Instalacion I (NOLOCK)
        ON LPM.IdInstalacion = I.IdInstalacion
    LEFT JOIN dbo.CO_GastosRubro rubro (NOLOCK)
        ON R.IdGastoRubro = rubro.IdGastoRubro
    LEFT JOIN dbo.CO_CAT_ManoDeObra catmo (NOLOCK)
        ON R.IdCatManoObra = catmo.Id
    LEFT JOIN dbo.FI_Factura F (NOLOCK)
        ON R.IdFactura = F.IdFactura
    LEFT JOIN dbo.FI_PedimentoComprobante PC (NOLOCK)
        ON R.IdPedimentoComprobante = PC.IdPedimentoComprobante

    /* ============================================================
       determinar FechaDoc para poder resolver mes/año del TC mensual (CIEP)
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

    /* ============================================================
       JOIN a #TCMensual (solo aplica cuando @EsCIEP = 1)
       - TCM_DOC  => TC mensual del mes del documento
       - TCM_PREV => TC mensual del mes anterior
       ============================================================ */
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
        ON PC.IdSubcontratistaExportador = SPC.IdSubcontratista
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
        ON LPM.IdArea = A.IdArea
    LEFT JOIN dbo.PV_TipoMoneda TMF (NOLOCK)
        ON F.IdMoneda = TMF.IdMoneda
    LEFT JOIN dbo.CO_TipoCambioDiario TCDF (NOLOCK)
        ON TMF.IdMoneda = TCDF.IdMoneda
       AND DAY(TCDF.Fecha) = DAY(F.Fecha)
       AND MONTH(TCDF.Fecha) = MONTH(F.Fecha)
       AND YEAR(TCDF.Fecha) = YEAR(F.Fecha)
    LEFT JOIN dbo.PV_TipoMoneda TMPC (NOLOCK)
        ON PC.IdMoneda = TMPC.IdMoneda
    LEFT JOIN dbo.CO_TipoCambioDiario TCDPC (NOLOCK)
        ON TMPC.IdMoneda = TCDPC.IdMoneda
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
    WHERE ((P.IdPresupuesto = @IdPresupuesto) OR @IdPresupuesto = -1)
      AND (R.IdRegistro IS NOT NULL)
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
        CASE
            WHEN P.CIEP = 1 THEN TS.NombreTipoServicio
            ELSE ACNH.DescripcionActividadPetrolera
        END,
        CASE
            WHEN P.CIEP = 1 THEN ACIEP.NombreActividad
            ELSE SAP.SubactividadPetrolera
        END,
        CASE
            WHEN P.CIEP = 1 THEN RI.NombreRubro
            ELSE TP.TareaPetrolera
        END,
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
        CASE
            WHEN R.CostosAtribuiblesAdministracion = 1 THEN 'SI'
            ELSE 'NO'
        END,
        CASE
            WHEN WA.IdDocAwsDocAdinco IS NULL AND R.CvTipoDocFacturacion = 1 THEN 'NO'
            WHEN WA.IdDocAwsDocAdinco IS NULL AND R.CvTipoDocFacturacion IN (2,3) THEN 'NA'
            ELSE 'SI'
        END,
        UM.Nombre,
        ISNULL(R.RegistroConAjuste, 0),
        ISNULL(R.AsociadoIncrementoPMT, 0)
    ORDER BY R.IdRegistro DESC;

    ---------------------------------------------------------------------
    -- Marcar CCN por Cartas Procura
    ---------------------------------------------------------------------
    UPDATE #Datos
    SET #Datos.CCN = 'SI'
    FROM #Datos D
    JOIN #CartasProcura CP
        ON D.Identificador = CP.IdFactura
    WHERE D.Identificador = CP.IdFactura
      AND D.TipoDocumento = 'CF';

    UPDATE #Datos
    SET #Datos.CCN = 'SI'
    FROM #Datos D
    JOIN #CartasProcura CP
        ON D.Identificador = CP.IdFactura
    WHERE D.Identificador = CP.IdFactura
      AND D.TipoDocumento = 'PE';

    ---------------------------------------------------------------------
    -- Reglas especiales Amatitlán
    ---------------------------------------------------------------------
    IF (@NombreAreaContractual = 'Amatitlán')
    BEGIN
        UPDATE #Datos
        SET #Datos.EstadoValidacion = ERV2.NombreEstado
        FROM #Datos D
        JOIN CO_RegistroMarkup RM
            ON D.IdRegistro = RM.GastoId
           AND RM.IdEstadoPemex IS NOT NULL
        JOIN CO_EstadoRegistro_V2 ERV2
            ON ERV2.Idcontrato = 10007
           AND RM.IdEstadoPemex = ERV2.IdClvEstado;
    END

    ---------------------------------------------------------------------
    -- Resultado final
    ---------------------------------------------------------------------
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
        d.ModificadoPor,
        d.RegistroConAjuste,
        d.AsociadoIncrementoPMT
    FROM #Datos d;
END
GO
