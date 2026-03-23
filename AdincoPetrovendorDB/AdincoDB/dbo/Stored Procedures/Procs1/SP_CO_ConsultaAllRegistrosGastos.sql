IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'SP_CO_ConsultaAllRegistrosGastos'
    )
    DROP PROCEDURE SP_CO_ConsultaAllRegistrosGastos;
GO
-- =============================================
-- Author:		Marcos Neri
-- Create date: 10-01-2020
-- Description:	*Agregar columna IdEstado
-- =============================================
-- Author:		 Marcos Garcia
-- Alter date:	 01-09-2021
-- Description: Add Cat Mano de Obra
-- =============================================
-- Author:		 Daniel Moreno
-- Alter date:	 05-04-2021
-- Description: Se agregan filtros de fechas
-- =============================================
-- Author:		Reyna O.
-- Create date: 30-06-2022
-- Description: Se agrega NOLOCK, se eliminan comentarios y se mueven las creaciones 
-- de la tabla al inicio de procedure, se eliminan algunos Left y Joins innecesarios
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_ConsultaAllRegistrosGastos] --10038,10,null,null,'	1800000076,1D60000180,01-0016	,FFF2FD08-F9CB-41CC-A0F4-17B62EB5D878	,FFF2FD08-F9CB-41CC-A0F4-17B62EB5D878 , D526DD6A-65DB-47B8-BAD9-F9EE35FE43DD'
    @IdContrato INT,
    @IdUsuario  INT,
    @UUIDFolios VARCHAR(MAX),
    @IdContratoSeleccionado INT
AS
    BEGIN
      
        SET NOCOUNT ON;

        IF OBJECT_ID('tempdb..#CartasProcura', 'U') IS NOT NULL
            DROP TABLE #CartasProcura;
        IF OBJECT_ID('tempdb..#Datos', 'U') IS NOT NULL
            DROP TABLE #Datos;

        IF OBJECT_ID('tempdb..#UUIDFolios', 'U') IS NOT NULL
            DROP TABLE #UUIDFolios;

        IF OBJECT_ID('tempdb..#Temp_UUIDFacturas', 'U') IS NOT NULL
            DROP TABLE #Temp_UUIDFacturas;


        CREATE TABLE #UUIDFolios (UUIDFolios VARCHAR(MAX));
        CREATE TABLE #Temp_UUIDFacturas
            (
                Id                INT IDENTITY(1, 1) PRIMARY KEY,
                CFDIAdincoId      INT,
                CFDIPetrovendorId INT,
                UUID              VARCHAR(150),
                FolioFactura      VARCHAR(150),
                NumeroPedimento   VARCHAR(150),
                FolioComprobante  VARCHAR(150),
                SistemaCartas     VARCHAR(150),
                FechaDocumento    DATE, --FECHA Factura, FECHAPAGO PE PI
                IdSubcontratista  INT,
                IdMoneda          INT,
                EsFactura         Bit
            );
        --=====================================================
        CREATE TABLE #CartasProcura
            (
                IdFacutraP INT,
                UUID       VARCHAR(150),
                IdFacutraA INT
            );

        /**/
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
                Subcontratista           VARCHAR(1000),
                InstalacionRegistro      VARCHAR(500),
                InicioEjecucion          DATE,
                FinEjecucion             DATE,
                CreadoPor                VARCHAR(500),
                MontoRegistro            FLOAT,
                Moneda                   VARCHAR(50),
                MesPresentacion          DATE,
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
                NombrePresupuesto        VARCHAR(1000),
                Rubro                    VARCHAR(500),
                CatManoObra              VARCHAR(500),
                PCN                      FLOAT,
                CAA                      VARCHAR(500),
                CCN                      VARCHAR(500),
                ModificadoPor            VARCHAR(500),
                CreacionGasto            DATE,
                IdEstado                 INT,
                UUID                     VARCHAR(200)
            );
        --------------
        IF (
               (
                   SELECT
                       LEN(@UUIDFolios)
               ) > 0
           )
            BEGIN

                INSERT INTO #UUIDFolios
                    (
                        UUIDFolios
                    )
                            SELECT DISTINCT
                                *
                            from
                                [dbo].[fnSplitString](@UUIDFolios, ',');

                UPDATE
                    #UUIDFolios
                SET
                    UUIDFolios = REPLACE(
                                            RTRIM(LTRIM(REPLACE(REPLACE(UUIDFolios, CHAR(10), ''), CHAR(13), ''))),
                                            '	',''
                                        );

                --Eliminación de vacios o null para que en el select no se incrementen facturas equivocadas
                DELETE #UUIDFolios
                WHERE
                    UUIDFolios IS NULL
                    OR UUIDFolios = '';

                --UUIDS
                INSERT INTO #Temp_UUIDFacturas
                    (
                        CFDIAdincoId,
                        UUID,
                        FolioFactura,
                        FechaDocumento,
                        IdSubcontratista,
                        IdMoneda,
                        EsFactura
                    )
                            SELECT DISTINCT
                                FI_FACTURA.IdFactura,
                                U.UUIDFolios,
                                LTRIM(RTRIM(FI_FACTURA.Serie + ' ' + FI_FACTURA.Folio)),
                                FI_FACTURA.Fecha,
                                FI_FACTURA.IdSubcontratista,
                                FI_FACTURA.IdMoneda,
                                1
                            FROM
                                #UUIDFolios U
                                JOIN
                                    FI_FACTURA	(NOLOCK)
                                        ON U.UUIDFolios = FI_FACTURA.UUID COLLATE DATABASE_DEFAULT
                                           AND FI_FACTURA.IdContrato = @IdContratoSeleccionado;

                DELETE UF
                FROM
                    #UUIDFolios            UF
                    LEFT JOIN
                        #Temp_UUIDFacturas TUF
                            ON UF.UUIDFolios = TUF.UUID
                WHERE
                    TUF.Id IS NOT NULL

                --Pedimentos Comprobantes
                INSERT INTO #Temp_UUIDFacturas
                    (
                        CFDIAdincoId,
                        FechaDocumento,
                        NumeroPedimento,
                        FolioComprobante,
                        IdSubcontratista,
                        IdMoneda,
                        EsFactura
                    )
                            SELECT DISTINCT
                                FI_PedimentoComprobante.IdPedimentoComprobante,
                                FI_PedimentoComprobante.FechaPago,
                                FI_PedimentoComprobante.NumeroPedimento,
                                FI_PedimentoComprobante.FolioComprobante,
                                FI_PedimentoComprobante.IdSubcontratistaExportador,
                                FI_PedimentoComprobante.IdMoneda,
                                0
                            FROM
                                #UUIDFolios U
                                JOIN
                                    FI_PedimentoComprobante	(NOLOCK)
                                        ON U.UUIDFolios = FI_PedimentoComprobante.NumeroPedimento COLLATE DATABASE_DEFAULT
                                           AND FI_PedimentoComprobante.IdContrato = @IdContratoSeleccionado
                            UNION ALL
                            SELECT DISTINCT
                                FI_PedimentoComprobante.IdPedimentoComprobante,
                                FI_PedimentoComprobante.FechaPago,
                                FI_PedimentoComprobante.NumeroPedimento,
                                FI_PedimentoComprobante.FolioComprobante,
                                FI_PedimentoComprobante.IdSubcontratistaExportador,
                                FI_PedimentoComprobante.IdMoneda,
                                0
                            FROM
                                #UUIDFolios U
                                JOIN
                                    FI_PedimentoComprobante	(NOLOCK)
                                        ON U.UUIDFolios = FI_PedimentoComprobante.FolioComprobante COLLATE DATABASE_DEFAULT
                                           AND FI_PedimentoComprobante.IdContrato = @IdContratoSeleccionado;

            END


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
                Subcontratista,
                InstalacionRegistro,
                InicioEjecucion,
                FinEjecucion,
                CreadoPor,
                MontoRegistro,
                Moneda,
                MesPresentacion,
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
                NombrePresupuesto,
                Rubro,
                CatManoObra,
                PCN,
                CAA,
                CCN,
                ModificadoPor,
                CreacionGasto,
                IdEstado,
                UUID
            )
                    SELECT
                        CO_Registro.IdRegistro,
                        CO_Servicio.NombreServicio                                          AS Servicio,
                        TF.UUID,
                        CO_LineaPresupuestoMes.AC_FEC_INI                                   AS FechaInicio,
                        CO_LineaPresupuestoMes.AC_FEC_FIN                                   AS FechaFin,
                        CASE
                            WHEN CO_Registro.CvTipoDocFacturacion = 1
                                THEN 'CF'
                            WHEN CO_Registro.CvTipoDocFacturacion = 2
                                THEN 'PI'
                            WHEN CO_Registro.CvTipoDocFacturacion = 3
                                THEN 'PE'
                        END                                                                 AS TipoDocumento,
                        CASE
                            WHEN CO_Registro.CvTipoDocFacturacion = 1
                                THEN TF.FolioFactura
                            WHEN CO_Registro.CvTipoDocFacturacion = 2
                                THEN TF.NumeroPedimento
                            WHEN CO_Registro.CvTipoDocFacturacion = 3
                                THEN TF.FolioComprobante
                        END                                AS Numero,
                        TF.FechaDocumento                                                   AS FechaDocumento,
                        SUM(   CASE
                                   WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0
                                       THEN ISNULL(CO_Registro.MontoRegistro, 0) / TCD.TipoCambio
                                   ELSE
                                       0
                               END
                           )                                                                AS MontoUSD,
                        PV_Subcontratista.RazonSocial                                       AS Subcontratista,
                        IR.NombreInstalacion                                                AS InstalacionRegistro,
                        CO_Registro.InicioEjecucion,
                        CO_Registro.FinEjecucion,
                        U.Nombre                                                            AS CreadoPor,
                        CO_Registro.MontoRegistro,
                        TM.TipoMonedaCorto                                                  AS Moneda,
                        CO_Registro.MesPresentacion                                         AS MesPresentacion,
                        CASE
                            WHEN CO_Presupuesto.CIEP = 1
                                THEN CO_TipoServicio.NombreTipoServicio
                            ELSE
                                CO_ActividadPetroleraCNH.DescripcionActividadPetrolera
                        END                                                                 AS TipoDeServicio,
                        CASE
                            WHEN CO_Presupuesto.CIEP = 1
                                THEN CO_ActividadCIEP.NombreActividad
                            ELSE
                                CO_SubactividadPetrolera.SubactividadPetrolera
                        END                                                                 AS Actividad,
                        CASE
                            WHEN CO_Presupuesto.CIEP = 1
                                THEN CO_RubroInterno.NombreRubro
                            ELSE
                                CO_TareaPetrolera.TareaPetrolera
                        END                                                                 AS SubActividad,
                        CO_EstadoRegistro.NombreEstado                                      AS EstadoValidacion,
                        CO_Area.NombreArea                                                  AS Area,
                        CO_Registro.Comentarios,
                        CO_ClasificacionAnexo4.ClasificacionAnexo4                          AS Anexo4,
                        TF.CFDIAdincoId                                                     AS Identificador,
                        CO_LineaPresupuestoMes.IdLineaPresupuestoMes                        AS LineaPresupuesto,
                        CO_Presupuesto.Nombre                                               AS Presupuesto,
                        CO_Presupuesto.Nombre + '[' + CO_Presupuesto.IdPresupuestoCNH + ']' AS NombrePresupuesto,
                        CO_GastosRubro.Descripcion                                          AS Rubro,
                        CO_CAT_ManoDeObra.Nombre                                            AS CatManoObra,
                        CO_Registro.PCN,
                        CASE
                            WHEN CO_Registro.CostosAtribuiblesAdministracion = 1
                                THEN 'SI'
                            ELSE
                                'NO'
                        END                                                                 AS CAA,
                        CASE
                            WHEN AWS_DocAwsDocAdinco.IdDocAwsDocAdinco IS NULL
                                 AND CO_Registro.CvTipoDocFacturacion = 1
                                THEN 'NO'
                            WHEN AWS_DocAwsDocAdinco.IdDocAwsDocAdinco IS NULL
                                 AND CO_Registro.CvTipoDocFacturacion IN (
                                                                             2, 3
                                                                         )
                                THEN 'NA'
                            ELSE
                                'SI'
                        END                                                                 AS CCN,
                        UM.Nombre                                                           AS ModificadoPor,
                        CAST(CO_Registro.FecMovto AS DATE)                                  AS CreacionGasto,
                        CO_Registro.IdEstado,
                        TF.UUID
                    FROM
                        #Temp_UUIDFacturas          TF
                        JOIN
                            dbo.CO_Registro (NOLOCK)
                                ON TF.CFDIAdincoId = CO_Registro.IdFactura
                                   OR TF.CFDIAdincoId = CO_Registro.IdPedimentoComprobante
                        INNER JOIN
                            dbo.CO_LineaPresupuestoMes (NOLOCK)
                                ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
                        INNER JOIN
                            dbo.CO_Presupuesto (NOLOCK)
                                ON CO_LineaPresupuestoMes.IdPresupuesto = CO_Presupuesto.IdPresupuesto
                        LEFT JOIN
                            dbo.CO_Servicio (NOLOCK)
                                ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
                        LEFT JOIN
                            dbo.CO_Instalacion (NOLOCK)
                                ON CO_LineaPresupuestoMes.IdInstalacion = CO_Instalacion.IdInstalacion
                        LEFT JOIN
                            dbo.CO_GastosRubro (NOLOCK)
                                ON CO_Registro.IdGastoRubro = CO_GastosRubro.IdGastoRubro
                        LEFT JOIN
                            dbo.CO_CAT_ManoDeObra (NOLOCK)
                                ON CO_Registro.IdCatManoObra = CO_CAT_ManoDeObra.Id
                        LEFT JOIN
                            dbo.PV_Subcontratista (NOLOCK)
                                ON TF.IdSubcontratista = PV_Subcontratista.IdSubcontratista
                        LEFT JOIN
                            dbo.CO_Instalacion      IR (NOLOCK)
                                ON CO_Registro.IdInstalacion = IR.IdInstalacion
                        LEFT JOIN
                            dbo.AP_Usuario          U (NOLOCK)
                                ON CO_Registro.IdUsuarioCreadoPor = U.UsuarioID
                        LEFT JOIN
                            dbo.CO_TipoServicio (NOLOCK)
                                ON CO_LineaPresupuestoMes.IdTipoServicio = CO_TipoServicio.IdTipoServicio
                        LEFT JOIN
                            dbo.CO_ActividadCIEP (NOLOCK)
                                ON CO_LineaPresupuestoMes.IdActividad = CO_ActividadCIEP.IdActividad
                        LEFT JOIN
                            dbo.CO_SubactividadCIEP (NOLOCK)
                                ON CO_LineaPresupuestoMes.IdSubactividad = CO_SubactividadCIEP.IdSubactividad
                        LEFT JOIN
                            dbo.CO_EstadoRegistro (NOLOCK)
                                ON CO_Registro.IdEstado = CO_EstadoRegistro.IdEstadoRegistro
                        LEFT JOIN
                            dbo.CO_Area (NOLOCK)
                                ON CO_LineaPresupuestoMes.IdArea = CO_Area.IdArea
                        LEFT JOIN
                            dbo.PV_TipoMoneda       TM (NOLOCK)
                                ON TF.IdMoneda = TM.IdMoneda
                        LEFT JOIN
                            dbo.CO_TipoCambioDiario TCD (NOLOCK)
                                ON TCD.IdMoneda = TM.IdMoneda
                                   AND DAY(TCD.Fecha) = DAY(TF.FechaDocumento)
                                   AND MONTH(TCD.Fecha) = MONTH(TF.FechaDocumento)
                                   AND YEAR(TCD.Fecha) = YEAR(TF.FechaDocumento)
                        LEFT JOIN
                            dbo.CO_ClasificacionAnexo4 (NOLOCK)
                                ON CO_LineaPresupuestoMes.IdAnexo4 = CO_ClasificacionAnexo4.IdAnexo4
                        LEFT JOIN
                            dbo.CO_ActividadPetroleraCNH (NOLOCK)
                                ON CO_LineaPresupuestoMes.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera
                        LEFT JOIN
                            dbo.CO_SubactividadPetrolera (NOLOCK)
                                ON CO_LineaPresupuestoMes.IdSubactividadPetrolera = CO_SubactividadPetrolera.IdSubactividadPetrolera
                        LEFT JOIN
                            dbo.CO_RubroInterno (NOLOCK)
                                ON CO_LineaPresupuestoMes.IdRubroInterno = CO_RubroInterno.IdRubroInterno
                        LEFT JOIN
                            dbo.CO_TareaPetrolera (NOLOCK)
                                ON CO_LineaPresupuestoMes.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera
                        LEFT JOIN
                            dbo.AWS_DocAwsDocAdinco (NOLOCK)
                                ON TF.CFDIAdincoId = AWS_DocAwsDocAdinco.IdDocAdinco
                        LEFT JOIN
                            dbo.AP_Usuario          UM (NOLOCK)
                                ON CO_Registro.IdUsuarioModPor = UM.UsuarioID
                    GROUP BY
                        TF.NumeroPedimento,
                        CO_Servicio.NombreServicio,
                        TF.UUID,
                        CO_LineaPresupuestoMes.AC_FEC_INI,
                        CO_LineaPresupuestoMes.AC_FEC_FIN,
                        TF.FechaDocumento,
                        TF.FolioFactura,
                        PV_Subcontratista.RazonSocial,
                        IR.NombreInstalacion,
                        CO_Registro.InicioEjecucion,
                        CO_Registro.FinEjecucion,
                        U.Nombre,
                        CO_Registro.MontoRegistro,
                        TM.TipoMonedaCorto,
                        CO_Registro.MesPresentacion,
                        CASE
                            WHEN CO_Presupuesto.CIEP = 1
                                THEN CO_TipoServicio.NombreTipoServicio
                            ELSE
                                CO_ActividadPetroleraCNH.DescripcionActividadPetrolera
                        END,
                        CASE
                            WHEN CO_Presupuesto.CIEP = 1
                                THEN CO_ActividadCIEP.NombreActividad
                            ELSE
                                CO_SubactividadPetrolera.SubactividadPetrolera
                        END,
                        CASE
                            WHEN CO_Presupuesto.CIEP = 1
                                THEN CO_RubroInterno.NombreRubro
                            ELSE
                                CO_TareaPetrolera.TareaPetrolera
                        END,
                        CO_Registro.IdRegistro,
                        CO_EstadoRegistro.NombreEstado,
                        CO_Area.NombreArea,
                        CO_Registro.Comentarios,
                        CO_ClasificacionAnexo4.ClasificacionAnexo4,
                        TF.CFDIAdincoId,
                        IR.CUIP,
                        IR.WelIID,
                        CO_LineaPresupuestoMes.IdLineaPresupuestoMes,
                        IR.IdInstalacion,
                        CO_Presupuesto.Nombre,
                        CO_Presupuesto.IdPresupuestoCNH,
                        CO_Registro.CvTipoDocFacturacion,
                        TF.IdMoneda,
                        CO_Registro.IdRegistro,
                        TF.FolioComprobante,
                        PV_Subcontratista.RazonSocial,
                        TM.TipoMonedaCorto,
                        CO_GastosRubro.Descripcion,
                        CO_CAT_ManoDeObra.Nombre,
                        CO_Registro.PCN,
                        CASE
                            WHEN CO_Registro.CostosAtribuiblesAdministracion = 1
                                THEN 'SI'
                            ELSE
                                'NO'
                        END,
                        CASE
                            WHEN AWS_DocAwsDocAdinco.IdDocAwsDocAdinco IS NULL
                                 AND CO_Registro.CvTipoDocFacturacion = 1
                                THEN 'NO'
                            WHEN AWS_DocAwsDocAdinco.IdDocAwsDocAdinco IS NULL
                                 AND CO_Registro.CvTipoDocFacturacion IN (
                                                                             2, 3
                                                                         )
                                THEN 'NA'
                            ELSE
                                'SI'
                        END,
                        UM.Nombre,
                        CAST(CO_Registro.FecMovto AS DATE),
                        CO_Registro.IdEstado
                    ORDER BY
                        CO_Registro.IdRegistro DESC;

        INSERT INTO #CartasProcura
            (
                IdFacutraP,
                UUID,
                IdFacutraA
            )
                    SELECT DISTINCT
                        FP.IdFactura,
                        FP.UUID,
                        datos.Identificador
                    FROM
                        #Datos                                    datos
                        JOIN
                            Petrovendor.dbo.FI_Factura            FP (NOLOCK)
                                ON FP.UUID = datos.UUID COLLATE DATABASE_DEFAULT
                                   AND FP.UUID IS NOT NULL
                                   AND FP.Activa = 1
                                   AND ISNULL(FP.IsEliminado, 0) <> 1
                        JOIN
                            Petrovendor.dbo.MM_AceptacionFactura  AF (NOLOCK)
                                ON AF.IdFactura = FP.IdFactura
                        JOIN
                            Petrovendor.dbo.MM_AceptacionPedido   AS AP (NOLOCK)
                                ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
                        JOIN
                            Petrovendor.dbo.MM_AceptacionCartaPCN AS AC (NOLOCK)
                                ON AC.IdAceptacionPedido = AP.IdAceptacionPedido
                                   AND AC.IdEstatus = 2
                                   AND ISNULL(AC.IdEstatusEliminado, 0) <> 1
                        JOIN
                            Petrovendor.dbo.S_Documento_S3        AS D (NOLOCK)
                                ON D.IdDocumento = AC.IdDocumento
                        JOIN
                            Petrovendor.dbo.MM_Pedido             AS P (NOLOCK)
                                ON P.IdPedido = AP.IdPedido
                                   AND P.IdContrato = @IdContratoSeleccionado;

        UPDATE
            D
        SET
            D.CCN = 'SI'
        FROM
            #Datos             D
            JOIN
                #CartasProcura CP
                    ON D.Identificador = CP.IdFacutraA
        WHERE
            D.Identificador = CP.IdFacutraA
            AND D.TipoDocumento = 'CF';


        SELECT
            IdRegistro,
            Servicio,
            InstalacionPresupuestada,
            FechaInicio,
            FechaFin,
            TipoDocumento,
            Numero,
            FechaDocumento,
            MontoUSD,
            Subcontratista,
            InstalacionRegistro,
            InicioEjecucion,
            FinEjecucion,
            CreadoPor,
            MontoRegistro,
            Moneda,
            MesPresentacion,
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
            NombrePresupuesto,
            Rubro,
            CatManoObra,
            PCN,
            CAA,
            CCN,
            ModificadoPor,
            CreacionGasto,
            IdEstado,
			UUID
        FROM
            #Datos
        ORDER BY
            MesPresentacion DESC;
    END;
