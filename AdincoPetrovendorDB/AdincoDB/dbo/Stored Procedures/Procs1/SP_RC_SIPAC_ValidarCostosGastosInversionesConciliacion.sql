IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_RC_SIPAC_ValidarCostosGastosInversionesConciliacion'
)
    DROP PROCEDURE SP_RC_SIPAC_ValidarCostosGastosInversionesConciliacion;
GO
-- =============================================  
-- Alter Author:        Reyna Olvera
-- Alter Date:			25 de Julio del 23
-- Alter Description:	Se agrega validación/alerta para mencionar al usuaario que la columna 21_22 y 21_23 tienen un valor de 0
-- ============================================= 
CREATE PROCEDURE [dbo].[SP_RC_SIPAC_ValidarCostosGastosInversionesConciliacion]  
    @Contrato INT,  
    @IdPresupuesto INT,  
    @Plantilla VARCHAR(150) = '',  
    @EsHistorico BIT = 0  
AS  
BEGIN  
    SET NOCOUNT ON;  
  
    --________________________________________ Verificacion de Tablas Temporales ________________________________________--  
    IF OBJECT_ID('tempdb..#TEMPORAL_21_M', 'U') IS NOT NULL  
        DROP TABLE #TEMPORAL_21_M;  
  
    IF OBJECT_ID('tempdb..#TEMPORAL_22_M', 'U') IS NOT NULL  
        DROP TABLE #TEMPORAL_22_M;  
  
    IF OBJECT_ID('tempdb..#TEMPORAL_23_M', 'U') IS NOT NULL  
        DROP TABLE #TEMPORAL_23_M;  
  
    IF OBJECT_ID('tempdb..#TEMPORAL_24_M', 'U') IS NOT NULL  
        DROP TABLE #TEMPORAL_24_M;  
  
    IF OBJECT_ID('tempdb..#TEMPORAL_25_M', 'U') IS NOT NULL  
        DROP TABLE #TEMPORAL_25_M;  
  
    IF OBJECT_ID('tempdb..#TEMPORAL_26_M', 'U') IS NOT NULL  
        DROP TABLE #TEMPORAL_26_M;  
  
    IF OBJECT_ID('tempdb..#DatosPresupuestos', 'U') IS NOT NULL  
        DROP TABLE #DatosPresupuestos;  
  
    IF OBJECT_ID('tempdb..#TEMPORAL_26_MContTemp', 'U') IS NOT NULL  
        DROP TABLE #TEMPORAL_26_MContTemp;  
	
	IF OBJECT_ID('tempdb..#TablaDeValidacionesConciliacion', 'U') IS NOT NULL  
        DROP TABLE #TablaDeValidacionesConciliacion;  

	DECLARE @Aprobado INT = 10004,
		@TipoFactura INT = 1,
		@PESO INT = 1,
		@DOLAR INT = 2,
		@TipoComplementoPago INT = 6,
		@TipoPedimentoImportacion INT = 2,
		@TipoComprobanteExtranjero INT = 3

    --________________________________________ Creación de Tablas Temporales ________________________________________--  
     CREATE TABLE #TablaDeValidacionesConciliacion 
	 (
		IdRowExcel INT IDENTITY(1,1),
		Validaciones VARCHAR(2000) NULL
	 );
	--________________________________________  
    CREATE TABLE #TEMPORAL_21_M  
    (  
        Id_21_M INT IDENTITY(11, 1),  
        IdContratista_RF_00 VARCHAR(2000),  
        IdContrato_RI_00 VARCHAR(2000),  
        NumeroContrato_RF01_01 VARCHAR(2000),  
        NumeroIdentificacion_RC21_00 VARCHAR(2000),  
        MesReporte_RC21_01 INT,  
        AnioReporte_RC21_02 INT,  
        NumeroConsecutivo_RC21_03 INT,  
        TipoDocumento_RC21_04 VARCHAR(2000),  
        UUID_RC21_05 VARCHAR(2000),  
        IUC_PI_RC21_06 VARCHAR(2000),  
        IUC_PE_RC21_07 VARCHAR(2000),  
        TipoComprobante_RC21_08 VARCHAR(2000),  
        MetodoPago_RC21_09 VARCHAR(2000),  
        Actividad_RC21_10 VARCHAR(2000),  
        SubActividad_RC21_11 VARCHAR(2000),  
        Tarea_RC21_12 VARCHAR(2000),  
        CostAtribAdminGral_RC21_13 BIT,  
        Campo_RC21_14 VARCHAR(2000),  
        Yacimiento_RC21_15 VARCHAR(2000),  
        Pozo_RC21_16 VARCHAR(2000),  
        NumCuentContable_RC21_17 VARCHAR(2000),  
        DescCuentaContable_RC21_18 VARCHAR(2000),  
        NumPoliContable_RC21_19 VARCHAR(2000),  
        ConcepOp_RC21_20 VARCHAR(2000),  
        GastoOpInver_RC21_21 INT,  
        MontoAumentar_RC21_22 FLOAT,  
        MontoDisminuir_RC21_23 FLOAT,  
        ClavaMoneda_RC21_24 VARCHAR(2000),  
        TipCamConvetUSD_RC21_25 FLOAT,  
        TipoOpercion_RC21_26 INT  
    );  
  
    IF (@Plantilla = 'CGI_2022')  
    BEGIN  
        ALTER TABLE #TEMPORAL_21_M  
        ADD RegistroConAjuste_RC21_27 INT NULL,  
            AsociadoIncrementoPMT_RC21_28 INT NULL;  
    END;  
  
    --________________________________________  
    CREATE TABLE #TEMPORAL_22_M  
    (  
        Id_22_M INT IDENTITY(11, 1),  
        IdContratista_RF_00 VARCHAR(2000),  
        IdContrato_RI_00 VARCHAR(2000),  
        NumeroContrato_RF01_01 VARCHAR(2000),  
        MesReporte_RC21_01 VARCHAR(2000),  
        AnioReporte_RC21_02 VARCHAR(2000),  
        NomArchivo_XML_RC22_02 VARCHAR(2000),  
        TimbreHASH_XML_RC22_03 VARCHAR(2000),  
        UUID_RC22_04 VARCHAR(2000),  
        TipoComprobante_RC22_05 VARCHAR(2000),  
        MetPago_RC22_06 VARCHAR(2000),  
        MontoTotal_RC22_07 MONEY,  
        Subtotal_RC22_08 MONEY,  
        MontoLiquida_RC22_09 MONEY,  
        NumParcialidad_RC22_10 INT,  
        FormPago_RC22_11 VARCHAR(2000),  
        FechaExpedicion_RC22_12 DATE,  
        RFC_Emisor_RC22_13 VARCHAR(2000),  
        LugarExpedicion_RC22_14 VARCHAR(2000),  
        RFC_Receptor_RC22_15 VARCHAR(2000),  
        ClaveMoneda_RC22_16 VARCHAR(2000),  
        ClasDocSoporte_RC22_17 INT  
    );  
  
    --________________________________________  
    CREATE TABLE #TEMPORAL_23_M  
    (  
        Id_23_M INT IDENTITY(11, 1),  
        IdContratista_RF_00 VARCHAR(2000),  
        IdContrato_RI_00 VARCHAR(2000),  
        NumeroContrato_RF01_01 VARCHAR(2000),  
        MesReporte_RC23_00 INT,  
        AnioReporte_RC23_01 INT,  
        UUID_RC23_02 VARCHAR(2000),  
        UUID_Relacionado_C23_03 VARCHAR(2000),  
        TipoRelacion_RC23_04 VARCHAR(2000),  
        NumParcialidad_RC23_05 INT  
    );  
  
    --________________________________________  
    CREATE TABLE #TEMPORAL_24_M  
    (  
        Id_24_M INT IDENTITY(11, 1),  
        IdContratista_RF_00 VARCHAR(2000),  
        IdContrato_RI_00 VARCHAR(2000),  
        NumeroContrato_RF01_01 VARCHAR(2000),  
        MesReporte_RC24_00 INT,  
        AnioReporte_RC24_01 INT,  
        NomArchivo_PDF_RC24_02 VARCHAR(2000),  
        TimbreHASH_PDF_RC24_03 VARCHAR(2000),  
        IDPedimentoImportacion_RC24_04 VARCHAR(2000),  
        AcuseElecValidacion_RC24_05 VARCHAR(2000),  
        ValorDolares_RC24_06 MONEY,  
        PrecioPagado_ValorComercial_RC24_07 MONEY,  
        ClavePedimento_RC24_08 VARCHAR(2000),  
        FormaPago_RC24_09 VARCHAR(2000),  
        FechaOriginal_RC24_10 DATE,  
        Regimen_RC24_11 VARCHAR(2000),  
        RFC_Importador_RC24_12 VARCHAR(13),  
        AduanaES_RC24_13 VARCHAR(2000),  
        IdFiscal_RC24_14 VARCHAR(30),  
        RazonSocialProv_RC24_15 VARCHAR(2000),  
        NumFactura_RC24_16 VARCHAR(2000),  
        FechaFactura_RC24_17 DATE,  
        ValMontFact_RC24_18 MONEY,  
        ValDolares_RC24_19 MONEY,  
        ClasDocSoporte_RC24_20 INT  
    );  
  
    --________________________________________  
    CREATE TABLE #TEMPORAL_25_M  
    (  
        Id_25_M INT IDENTITY(11, 1),  
        IdContratista_RF_00 VARCHAR(2000),  
        IdContrato_RI_00 VARCHAR(2000),  
        NumeroContrato_RF01_01 VARCHAR(2000),  
        MesReporte_RC25_00 INT,  
        AnioReporte_RC25_01 INT,  
        NomArchivo_PDF_RC25_02 VARCHAR(2000),  
        TimbreHASH_PDF_RC25_03 VARCHAR(2000),  
        IdDocFacturacion_RC25_04 VARCHAR(2000),  
        FolioCompExtranjero_RC25_05 VARCHAR(2000),  
        ImporteTotalAntesImpuestos_RC25_06 MONEY,  
        FormaPago_RC25_07 VARCHAR(2000),  
        FechaPago_RC25_08 DATE,  
        RFC_Importador_RC25_09 VARCHAR(2000),  
        RZImportador_RC25_10 VARCHAR(2000),  
        RZEmisorCompExtranjero_RC25_11 VARCHAR(2000),  
        IdFiscal_RC25_12 VARCHAR(2000),  
        NumFactura_RC25_13 VARCHAR(2000),  
        FechaFactura_RC25_14 DATE,  
        ValMontFact_RC25_15 MONEY,  
        ValDolares_RC25_16 MONEY,  
        ClasDocSoporte_RC25_17 INT  
    );  
  
    --________________________________________  
    CREATE TABLE #TEMPORAL_26_M  
    (  
        Id_26_M INT IDENTITY(11, 1),  
        IdContratista_RF_00 VARCHAR(2000),  
        IdContrato_RI_00 VARCHAR(2000),  
        MesReporte_RC26_00 INT,  
        AnioReporte_RC26_01 INT,  
        FormaPago_RC26_02 VARCHAR(2000),  
        IdDocFacturacion_RC26_03 VARCHAR(2000),  
        FechaPago_RC26_04 DATE,  
        NomArchivo_PDF_RC26_05 VARCHAR(2000),  
        TimbreHASH_PDF_RC26_06 VARCHAR(2000),  
        MontoPagado_RC26_07 MONEY,  
        ClaveMonedaFactura_RC26_08 VARCHAR(2000),  
 MontoEquivDolare_RC26_09 FLOAT,  
        TipoCambio_RC26_10 FLOAT,  
        Beneficiario_RC26_11 VARCHAR(2000),  
        ClasDocSoporte_RC26_12 INT  
    );  
  
    --________________________________________  
  
    --________________________________________  
    CREATE TABLE #DatosPresupuestos  
    (  
        IdPresupuesto INT,  
        Nombre VARCHAR(2000),  
        IdPresupuestoCNH VARCHAR(150),  
        FechaInicioPresupuesto DATE,  
        FechaFinPresupuesto DATE  
    );  
  
    --________________________________________  
    CREATE TABLE #TEMPORAL_26_MContTemp  
    (  
        NombreArchivo VARCHAR(2000),  
        TimbreHASH VARCHAR(2000)  
    );  
  
 DECLARE @Count INT;  
 DECLARE @Reporte INT;  
  
    --________________________________________ Insercion en las Tablas Temporales ________________________________________--  
    --________________________________________  
    IF (@Plantilla = 'CGI_2022')  
    BEGIN  
        INSERT INTO #TEMPORAL_21_M  
        (  
            IdContratista_RF_00,  
            IdContrato_RI_00,  
            NumeroContrato_RF01_01,  
            NumeroIdentificacion_RC21_00,  
            MesReporte_RC21_01,  
            AnioReporte_RC21_02,  
            NumeroConsecutivo_RC21_03,  
            TipoDocumento_RC21_04,  
            UUID_RC21_05,  
            IUC_PI_RC21_06,  
            IUC_PE_RC21_07,  
            TipoComprobante_RC21_08,  
            MetodoPago_RC21_09,  
            Actividad_RC21_10,  
            SubActividad_RC21_11,  
            Tarea_RC21_12,  
            CostAtribAdminGral_RC21_13,  
            Campo_RC21_14,  
            Yacimiento_RC21_15,  
            Pozo_RC21_16,  
            NumCuentContable_RC21_17,  
            DescCuentaContable_RC21_18,  
            NumPoliContable_RC21_19,  
            ConcepOp_RC21_20,  
            GastoOpInver_RC21_21,  
            MontoAumentar_RC21_22,  
            MontoDisminuir_RC21_23,  
            ClavaMoneda_RC21_24,  
            TipCamConvetUSD_RC21_25,  
            TipoOpercion_RC21_26,  
            RegistroConAjuste_RC21_27,  
            AsociadoIncrementoPMT_RC21_28  
        )  
        EXEC dbo.SIPAC_RC_CONT_21_MConciliacion @Contrato, @IdPresupuesto, @Plantilla;  
    END  
    ELSE  
    BEGIN  
        INSERT INTO #TEMPORAL_21_M  
        (  
            IdContratista_RF_00,  
            IdContrato_RI_00,  
            NumeroContrato_RF01_01,  
         NumeroIdentificacion_RC21_00,  
            MesReporte_RC21_01,  
            AnioReporte_RC21_02,  
            NumeroConsecutivo_RC21_03,  
            TipoDocumento_RC21_04,  
            UUID_RC21_05,  
            IUC_PI_RC21_06,  
            IUC_PE_RC21_07,  
            TipoComprobante_RC21_08,  
            MetodoPago_RC21_09,  
            Actividad_RC21_10,  
            SubActividad_RC21_11,  
            Tarea_RC21_12,  
            CostAtribAdminGral_RC21_13,  
            Campo_RC21_14,  
            Yacimiento_RC21_15,  
            Pozo_RC21_16,  
            NumCuentContable_RC21_17,  
            DescCuentaContable_RC21_18,  
            NumPoliContable_RC21_19,  
            ConcepOp_RC21_20,  
            GastoOpInver_RC21_21,  
            MontoAumentar_RC21_22,  
            MontoDisminuir_RC21_23,  
            ClavaMoneda_RC21_24,  
            TipCamConvetUSD_RC21_25,  
            TipoOpercion_RC21_26  
        )  
        EXEC dbo.SIPAC_RC_CONT_21_MConciliacion @Contrato, @IdPresupuesto, @Plantilla;  
    END  
  
    --________________________________________  
    INSERT INTO #TEMPORAL_22_M  
    (  
        IdContratista_RF_00,  
        IdContrato_RI_00,  
        NumeroContrato_RF01_01,  
        MesReporte_RC21_01,  
        AnioReporte_RC21_02,  
        NomArchivo_XML_RC22_02,  
        TimbreHASH_XML_RC22_03,  
        UUID_RC22_04,  
        TipoComprobante_RC22_05,  
        MetPago_RC22_06,  
        MontoTotal_RC22_07,  
        Subtotal_RC22_08,  
        MontoLiquida_RC22_09,  
        NumParcialidad_RC22_10,  
        FormPago_RC22_11,  
        FechaExpedicion_RC22_12,  
        RFC_Emisor_RC22_13,  
        LugarExpedicion_RC22_14,  
        RFC_Receptor_RC22_15,  
        ClaveMoneda_RC22_16,  
        ClasDocSoporte_RC22_17  
    )  
    EXEC dbo.SIPAC_RC_CONT_22_MConciliacion @Contrato, @IdPresupuesto, @Plantilla;  
  
    --________________________________________  
    INSERT INTO #TEMPORAL_23_M  
    (  
        IdContratista_RF_00,  
        IdContrato_RI_00,  
        NumeroContrato_RF01_01,  
        MesReporte_RC23_00,  
        AnioReporte_RC23_01,  
        UUID_RC23_02,  
        UUID_Relacionado_C23_03,  
        TipoRelacion_RC23_04,  
        NumParcialidad_RC23_05  
    )  
    EXEC dbo.SIPAC_RC_CONT_23_MConciliacion @Contrato, @IdPresupuesto, @Plantilla;  
  
    --________________________________________  
    INSERT INTO #TEMPORAL_24_M  
    (  
        IdContratista_RF_00,  
        IdContrato_RI_00,  
        NumeroContrato_RF01_01,  
        MesReporte_RC24_00,  
        AnioReporte_RC24_01,  
        NomArchivo_PDF_RC24_02,  
        TimbreHASH_PDF_RC24_03,  
        IDPedimentoImportacion_RC24_04,  
        AcuseElecValidacion_RC24_05,  
        ValorDolares_RC24_06,  
        PrecioPagado_ValorComercial_RC24_07,  
        ClavePedimento_RC24_08,  
        FormaPago_RC24_09,  
        FechaOriginal_RC24_10,  
        Regimen_RC24_11,  
        RFC_Importador_RC24_12,  
        AduanaES_RC24_13,  
        IdFiscal_RC24_14,  
        RazonSocialProv_RC24_15,  
        NumFactura_RC24_16,  
        FechaFactura_RC24_17,  
        ValMontFact_RC24_18,  
        ValDolares_RC24_19,  
        ClasDocSoporte_RC24_20  
    )  
    EXECUTE dbo.SIPAC_RC_CONT_24_MConciliacion @Contrato, @IdPresupuesto, @Plantilla;  
  
    --________________________________________  
    INSERT INTO #TEMPORAL_25_M  
    (  
        IdContratista_RF_00,  
        IdContrato_RI_00,  
        NumeroContrato_RF01_01,  
        MesReporte_RC25_00,  
        AnioReporte_RC25_01,  
        NomArchivo_PDF_RC25_02,  
        TimbreHASH_PDF_RC25_03,  
        IdDocFacturacion_RC25_04,  
        FolioCompExtranjero_RC25_05,  
        ImporteTotalAntesImpuestos_RC25_06,  
        FormaPago_RC25_07,  
        FechaPago_RC25_08,  
        RFC_Importador_RC25_09,  
        RZImportador_RC25_10,  
        RZEmisorCompExtranjero_RC25_11,  
        IdFiscal_RC25_12,  
        NumFactura_RC25_13,  
        FechaFactura_RC25_14,  
        ValMontFact_RC25_15,  
        ValDolares_RC25_16,  
        ClasDocSoporte_RC25_17  
    )  
    EXECUTE dbo.SIPAC_RC_CONT_25_MConciliacion @Contrato, @IdPresupuesto, @Plantilla;  
  
    --________________________________________  
    INSERT INTO #TEMPORAL_26_M  
    (  
        IdContratista_RF_00,  
        IdContrato_RI_00,  
        MesReporte_RC26_00,  
        AnioReporte_RC26_01,  
        FormaPago_RC26_02,  
        IdDocFacturacion_RC26_03,  
        FechaPago_RC26_04,  
        NomArchivo_PDF_RC26_05,  
        TimbreHASH_PDF_RC26_06,  
        MontoPagado_RC26_07,  
        ClaveMonedaFactura_RC26_08,  
        MontoEquivDolare_RC26_09,  
        TipoCambio_RC26_10,  
        Beneficiario_RC26_11,  
        ClasDocSoporte_RC26_12  
    )  
    EXECUTE dbo.SIPAC_RC_CONT_26_MConciliacion @Contrato, @IdPresupuesto, @Plantilla;  
  
    --________________________________________  
  
    --________________________________________  
    INSERT INTO #DatosPresupuestos  
    (  
        IdPresupuesto,  
        Nombre,  
        IdPresupuestoCNH,  
        FechaInicioPresupuesto,  
        FechaFinPresupuesto  
    )  
    SELECT P.IdPresupuesto,  
           P.Nombre,  
           P.IdPresupuestoCNH,  
           P.InicioPresupuesto,  
       P.FinPresupuesto  
    FROM dbo.FI_TransferFactura TF WITH (NOLOCK)  
        JOIN dbo.CO_Registro R WITH (NOLOCK)  
            ON TF.IdFactura = R.IdFactura  
        JOIN dbo.FI_Factura F WITH (NOLOCK)  
            ON R.IdFactura = F.IdFactura   
               AND R.IdEstado = @Aprobado  
               AND ISNULL(CONVERT(INT, F.ProcesadoSIPAC), 0) = 0  
               AND R.CvTipoDocFacturacion = @TipoFactura  
               AND F.IdContrato = @Contrato  
        JOIN dbo.CO_Contrato C WITH (NOLOCK)  
            ON F.IdContrato = C.IdContrato  
               AND F.IdContrato = @Contrato  
        JOIN dbo.CO_LineaPresupuestoMes LPM WITH (NOLOCK)  
            ON R.IdPrograma = LPM.IdLineaPresupuestoMes  
        JOIN dbo.CO_Presupuesto P WITH (NOLOCK)  
            ON LPM.IdPresupuesto = P.IdPresupuesto  
        JOIN dbo.CO_Servicio S WITH (NOLOCK)  
            ON LPM.IdServicio = S.IdServicio  
               AND S.NombreServicio NOT LIKE '%No elegibles%'  
               AND S.IdContrato = C.IdContrato  
    WHERE P.IdPresupuesto = CASE  
                                WHEN @IdPresupuesto = 0 THEN  
                                    LPM.IdPresupuesto  
                                ELSE  
                                    @IdPresupuesto  
                            END  
    GROUP BY P.IdPresupuesto,  
             P.Nombre,  
             P.IdPresupuestoCNH,  
             P.InicioPresupuesto,  
             P.FinPresupuesto  
    UNION  
    SELECT P.IdPresupuesto,  
           P.Nombre,  
          P.IdPresupuestoCNH,  
           P.InicioPresupuesto,  
           P.FinPresupuesto  
    FROM dbo.FI_TransferFactura TF WITH (NOLOCK)  
        JOIN dbo.FI_ComplementoDePago CP WITH (NOLOCK)  
            ON TF.IdFactura = CP.IdFactura  
        JOIN dbo.FI_CPDocRelacionado DR WITH (NOLOCK)  
            ON CP.IdComplementoDePago = DR.IdComplementoDePago  
        JOIN dbo.FI_Factura F WITH (NOLOCK)  
            ON DR.IdDocumento = F.UUID  
               AND ISNULL(CONVERT(INT, F.ProcesadoSIPAC), 0) = 0  
               AND F.IdContrato = @Contrato  
        JOIN dbo.CO_Registro R WITH (NOLOCK)  
            ON F.IdFactura = R.IdFactura  
               AND R.IdEstado = @Aprobado  
               AND R.CvTipoDocFacturacion = @TipoFactura  
        JOIN dbo.CO_Contrato C WITH (NOLOCK)  
            ON F.IdContrato = C.IdContrato  
               AND F.IdContrato = @Contrato  
        JOIN dbo.CO_LineaPresupuestoMes LPM WITH (NOLOCK)  
            ON R.IdPrograma = LPM.IdLineaPresupuestoMes  
        JOIN dbo.CO_Presupuesto P WITH (NOLOCK)  
            ON LPM.IdPresupuesto = P.IdPresupuesto  
        JOIN dbo.CO_Servicio S WITH (NOLOCK)  
            ON LPM.IdServicio = S.IdServicio  
               AND S.NombreServicio NOT LIKE '%No elegibles%'  
               AND S.IdContrato = C.IdContrato  
    WHERE P.IdPresupuesto = CASE  
                                WHEN @IdPresupuesto = 0 THEN  
                                    LPM.IdPresupuesto  
                                ELSE  
                                    @IdPresupuesto  
                            END  
    GROUP BY P.IdPresupuesto,  
             P.Nombre,  
             P.IdPresupuestoCNH,  
             P.InicioPresupuesto,  
             P.FinPresupuesto  
    UNION  
    SELECT Pre.IdPresupuesto,  
           Pre.Nombre,  
           Pre.IdPresupuestoCNH,  
           Pre.InicioPresupuesto,  
           Pre.FinPresupuesto  
    FROM dbo.FI_Transfer T WITH (NOLOCK)  
        JOIN dbo.FI_TransferFactura TF WITH (NOLOCK)  
            ON T.IdTransferencia = TF.IdTransfer  
        JOIN dbo.FI_PedimentoComprobante P WITH (NOLOCK)  
            ON TF.IdPedimentoComprobante = P.IdPedimentoComprobante  
               AND ISNULL(CONVERT(INT, P.ProcesadoSIPAC), 0) = 0  
        JOIN dbo.CO_Registro R WITH (NOLOCK)  
            ON P.IdPedimentoComprobante = R.IdPedimentoComprobante  
               AND R.IdEstado = @Aprobado  
               AND R.CvTipoDocFacturacion IN ( @TipoPedimentoImportacion, @TipoComprobanteExtranjero )  
        JOIN dbo.CO_Contrato C WITH (NOLOCK)  
            ON P.IdContrato = C.IdContrato  
               AND C.IdContrato = @Contrato  
        JOIN dbo.CO_LineaPresupuestoMes LPM WITH (NOLOCK)  
            ON R.IdPrograma = LPM.IdLineaPresupuestoMes  
        JOIN dbo.CO_Presupuesto Pre WITH (NOLOCK)  
            ON LPM.IdPresupuesto = Pre.IdPresupuesto  
        JOIN dbo.CO_Servicio S WITH (NOLOCK)  
            ON LPM.IdServicio = S.IdServicio  
               AND S.NombreServicio NOT LIKE '%No elegibles%'  
    WHERE PRE.IdPresupuesto = CASE  
                                  WHEN @IdPresupuesto = 0 THEN  
                                      LPM.IdPresupuesto  
                                  ELSE  
                                      @IdPresupuesto  
                              END  
    GROUP BY Pre.IdPresupuesto,  
             Pre.Nombre,  
             Pre.IdPresupuestoCNH,  
             Pre.InicioPresupuesto,  
             Pre.FinPresupuesto;  
  
    --_______________________________________________  
    INSERT INTO #TEMPORAL_26_MContTemp  
    (  
        NombreArchivo,  
        TimbreHASH  
    )  
    SELECT T26.NomArchivo_PDF_RC26_05,  
           T26.TimbreHASH_PDF_RC26_06  
    FROM #TEMPORAL_26_M T26  
    GROUP BY T26.NomArchivo_PDF_RC26_05,  
             T26.TimbreHASH_PDF_RC26_06  
    HAVING COUNT(T26.NomArchivo_PDF_RC26_05) <= 1;  
  
    --_______________________________________________  
  
    SET @Count =  
    (  
        SELECT COUNT(*)  
        FROM #DatosPresupuestos DP  
        WHERE DP.IdPresupuestoCNH IS NULL  
              OR DP.IdPresupuestoCNH = ''  
              OR DP.IdPresupuestoCNH = 'FALTA ID'  
    );  
  
    --_______________________________________________________________________________________________--  
  
    IF (@Plantilla = 'CGI_2022')  
    BEGIN  
        SET @Reporte =  
        (  
            SELECT COUNT(Id_21_M)  
            FROM #TEMPORAL_21_M  
            WHERE TipoDocumento_RC21_04 IS NULL  
                  AND UUID_RC21_05 IS NULL  
                  AND IUC_PI_RC21_06 IS NULL  
                  AND IUC_PE_RC21_07 IS NULL  
                  AND TipoComprobante_RC21_08 IS NULL  
                  AND MetodoPago_RC21_09 IS NULL  
                  AND Actividad_RC21_10 IS NULL  
                  AND SubActividad_RC21_11 IS NULL  
                  AND Tarea_RC21_12 IS NULL  
                  AND CostAtribAdminGral_RC21_13 IS NULL  
                  AND Campo_RC21_14 IS NULL  
                  AND Yacimiento_RC21_15 IS NULL  
                  AND Pozo_RC21_16 IS NULL  
                  AND NumCuentContable_RC21_17 IS NULL  
                  AND DescCuentaContable_RC21_18 IS NULL  
                  AND NumPoliContable_RC21_19 IS NULL  
                  AND ConcepOp_RC21_20 IS NULL  
                  AND GastoOpInver_RC21_21 IS NULL  
                  AND MontoAumentar_RC21_22 = 0  
                  AND MontoDisminuir_RC21_23 = 0  
                  AND ClavaMoneda_RC21_24 IS NULL  
                  AND TipCamConvetUSD_RC21_25 IS NULL  
                  AND TipoOpercion_RC21_26 IS NULL  
                  AND RegistroConAjuste_RC21_27 = 0  
                  AND AsociadoIncrementoPMT_RC21_28 IS NULL  
        );  
    END  
    ELSE  
    BEGIN  
        SET @Reporte =  
        (  
            SELECT COUNT(Id_21_M)  
            FROM #TEMPORAL_21_M  
            WHERE TipoDocumento_RC21_04 IS NULL  
                  AND UUID_RC21_05 IS NULL  
                  AND IUC_PI_RC21_06 IS NULL  
                  AND IUC_PE_RC21_07 IS NULL  
                  AND TipoComprobante_RC21_08 IS NULL  
                  AND MetodoPago_RC21_09 IS NULL  
     AND Actividad_RC21_10 IS NULL  
                  AND SubActividad_RC21_11 IS NULL  
                  AND Tarea_RC21_12 IS NULL  
                  AND CostAtribAdminGral_RC21_13 IS NULL  
                  AND Campo_RC21_14 IS NULL  
                  AND Yacimiento_RC21_15 IS NULL  
                  AND Pozo_RC21_16 IS NULL  
                  AND NumCuentContable_RC21_17 IS NULL  
                  AND DescCuentaContable_RC21_18 IS NULL  
                  AND NumPoliContable_RC21_19 IS NULL  
                  AND ConcepOp_RC21_20 IS NULL  
                  AND GastoOpInver_RC21_21 IS NULL  
                  AND MontoAumentar_RC21_22 = 0  
                  AND MontoDisminuir_RC21_23 = 0  
                  AND ClavaMoneda_RC21_24 IS NULL  
                  AND TipCamConvetUSD_RC21_25 IS NULL  
                  AND TipoOpercion_RC21_26 IS NULL  
        );  
    END  
	

    IF (@Reporte <> 0)  
    BEGIN  
        SELECT ' La plantilla se reportará en 0 ya que no se encontró ningún gasto en el mes seleccionado' AS Validacion,  
               @Reporte AS [Contador];  
    END;  
    ELSE  
    BEGIN  
			--________________________________________ Validaciones ________________________________________-- 
			--0______________________________Verificacion Presupuesto_______________________________--  
			INSERT INTO #TablaDeValidacionesConciliacion (Validaciones)
			SELECT CASE  
                       WHEN IdPresupuestoCNH IS NULL  
                            OR IdPresupuestoCNH = ''  
                            OR IdPresupuestoCNH = 'FALTA ID' THEN  
                           '¡Alerta! No sé a proporcionado la fecha de inicio o fecha de fin del presupuesto con Nombre: [ '  
             + Nombre + ' ].'  
                       ELSE  
                           '¡Alerta! No sé a proporcionado la fecha de inicio o fecha de fin del presupuesto: [ '  
                           + Nombre + ' - ' + SUBSTRING(IdPresupuestoCNH, LEN(IdPresupuestoCNH) - 8, 9) + ' ].'  
                   END AS Validaciones  
            FROM #DatosPresupuestos  
            WHERE FechaInicioPresupuesto IS NULL  
                  OR FechaFinPresupuesto IS NULL  
			----------------------------  
            INSERT INTO #TablaDeValidacionesConciliacion (Validaciones)
            SELECT CASE  
                       WHEN @Count = 1 THEN  
                           '¡Alerta! No sé a proporcionado el identificador CNH del Presupuesto [' + DP.Nombre + '].'  
                       ELSE  
                           '¡Alerta! No sé a proporcionado el identificador CNH de los Presupuestos ['  
                           + STUFF(  
                             (  
                                 SELECT DISTINCT  
                                     ', ' + CONVERT(VARCHAR(2000), DPA.Nombre)  
                                 FROM #DatosPresupuestos DPA  
                                 WHERE DPA.IdPresupuestoCNH IS NULL  
                                       OR DPA.IdPresupuestoCNH = ''  
                                       OR DPA.IdPresupuestoCNH = 'FALTA ID'  
                                 FOR XML PATH('')  
                             ),  
                             1,  
                             2,  
                             ''  
                                  ) + '].'  
                   END AS Validaciones  
            FROM #DatosPresupuestos DP  
            WHERE DP.IdPresupuestoCNH IS NULL  
                  OR DP.IdPresupuestoCNH = ''  
                  OR DP.IdPresupuestoCNH = 'FALTA ID'   
			----------------------------  
            INSERT INTO #TablaDeValidacionesConciliacion (Validaciones)
            SELECT CASE  
                       WHEN IdPresupuestoCNH IS NULL  
                            OR IdPresupuestoCNH = ''  
                            OR IdPresupuestoCNH = 'FALTA ID' THEN  
                           '¡Alerta! El presupuesto: [ ' + Nombre + ' ] con fecha fin vigencia '  
                           + CONVERT(VARCHAR(2000), FechaFinPresupuesto) + ' está fuera del periodo.'  
                       ELSE  
                           '¡Alerta! El presupuesto: [ ' + Nombre + ' - '  
                           + SUBSTRING(IdPresupuestoCNH, LEN(IdPresupuestoCNH) - 8, 9) + ' ] con fecha fin vigencia '  
                           + CONVERT(VARCHAR(2000), FechaFinPresupuesto) + ' está fuera del periodo.'  
                   END AS Validaciones  
            FROM #DatosPresupuestos  
            WHERE FechaFinPresupuesto IS NOT NULL  
                  AND @EsHistorico = 0  
			----------------------------  
            INSERT INTO #TablaDeValidacionesConciliacion (Validaciones)
            SELECT CASE  
                       WHEN IdPresupuestoCNH IS NULL  
                            OR IdPresupuestoCNH = ''  
                            OR IdPresupuestoCNH = 'FALTA ID' THEN  
                           '¡Alerta! El presupuesto: [ ' + Nombre + ' ] con fecha fin vigencia '  
                           + CONVERT(VARCHAR(2000), FechaFinPresupuesto)  
                           + ' está fuera de los últimos 6 meses permitidos.'  
                       ELSE  
                           '¡Alerta! El presupuesto: [ ' + Nombre + ' - '  
                           + SUBSTRING(IdPresupuestoCNH, LEN(IdPresupuestoCNH) - 8, 9) + ' ] con fecha fin vigencia '  
                           + CONVERT(VARCHAR(2000), FechaFinPresupuesto)  
                           + ' está fuera de los últimos 6 meses permitidos.'  
                   END AS Validaciones  
            FROM #DatosPresupuestos  
            WHERE FechaFinPresupuesto IS NOT NULL  
                  AND @EsHistorico = 0 
            --1______________________________Complemento de Pago sea PPD_______________________________--  
            INSERT INTO #TablaDeValidacionesConciliacion (Validaciones)
			SELECT ('El complemento de pago se Registró como PUE en vez de PPD, en la Hoja RC_CONT_22_M en la columna RC22_06 Renglón: '  
                    + CONVERT(VARCHAR(2000), T22.Id_22_M)  
                    + ', referente en la Hoja RC_CONT_23_M en la columna RC23_03 Renglón: '  
                    + CONVERT(VARCHAR(2000), T23.Id_23_M)  
                   ) + '.' AS [Validaciones]  
            FROM #TEMPORAL_23_M T23  
                INNER JOIN #TEMPORAL_22_M T22  
                    ON T23.UUID_Relacionado_C23_03 = T22.UUID_RC22_04  
            WHERE T22.MetPago_RC22_06 = 'PUE'  
                  AND T22.TipoComprobante_RC22_05 = 'I' 
			ORDER BY T22.Id_22_M ASC  
            --2_______________________________Monto Total Mayor o Igual que (Subtotal y Monto Liquida)__--  
			INSERT INTO #TablaDeValidacionesConciliacion (Validaciones)
            SELECT CASE  
                       WHEN (T22.Subtotal_RC22_08 > T22.MontoTotal_RC22_07)  
                            AND (T22.MontoLiquida_RC22_09 > T22.MontoTotal_RC22_07) THEN  
                           'El Subtotal, así como Monto que se Liquida son mayores que el Monto Total del comprobante de Facturación, Verificar en la Hoja RC_CONT_22_M en las columnas RC22_08, RC22_09 Renglón: '  
                           + CONVERT(VARCHAR(2000), T22.Id_22_M) + '.'  
                       WHEN T22.Subtotal_RC22_08 > T22.MontoTotal_RC22_07 THEN  
                           'El Subtotal es mayor que el Monto Total del comprobante de Facturación, Verificar en la Hoja RC_CONT_22_M en la columna RC22_08 Renglón: '  
                           + CONVERT(VARCHAR(2000), T22.Id_22_M) + '.'  
                       WHEN T22.MontoLiquida_RC22_09 > T22.MontoTotal_RC22_07 THEN  
                           'El Monto que se Liquida es mayor que el Monto Total del comprobante de Facturación, Verificar en la Hoja RC_CONT_22_M en la columna RC22_09 Renglón: '  
                           + CONVERT(VARCHAR(2000), T22.Id_22_M) + '.'  
                   END AS [Validaciones]  
            FROM #TEMPORAL_22_M AS T22  
            WHERE T22.Subtotal_RC22_08 > T22.MontoTotal_RC22_07  
                  OR T22.MontoLiquida_RC22_09 > T22.MontoTotal_RC22_07 
			ORDER BY T22.Id_22_M ASC 
            --3 _____________________________ Fecha Menor o Igual al ultimo dia Natural(2 meses extra aun para recibir) _______________--  
            --SELECT CASE  
            --           WHEN T26.IdDocFacturacion_RC26_03 IS NULL  
            --                OR T26.IdDocFacturacion_RC26_03 = 'NA' THEN  
            --               'Verificar en la Hoja RC_CONT_26_M en la columna RC26_04 Renglón: '  
            --               + CONVERT(VARCHAR(2000), T26.Id_26_M) + ', ya que el documento tiene '  
            --               + CONVERT(NVARCHAR, (DATEDIFF(MONTH, T26.FechaPago_RC26_04, @Mes)))  
            --               + '  meses de atraso de los 90 días (3 meses permitidos).'  
            --           ELSE  
            --               'Verificar en la Hoja RC_CONT_26_M en la columna RC26_04 Renglón: '  
            --               + CONVERT(VARCHAR(2000), T26.Id_26_M) + ', ya que el documento tiene '  
            --               + CONVERT(NVARCHAR, (DATEDIFF(MONTH, T26.FechaPago_RC26_04, @Mes)))  
            --               + '  meses de atraso de los 90 días (3 meses permitidos) con el ID del Documento: '  
            --               + T26.IdDocFacturacion_RC26_03 + '.'  
            --       END AS [Validaciones]  
            --FROM #TEMPORAL_26_M T26  
            --WHERE DATEDIFF(MONTH, T26.FechaPago_RC26_04, @Mes) > 3  
            --UNION 
            ------------------------               
            --SELECT CASE  
            --           WHEN T26.IdDocFacturacion_RC26_03 IS NULL  
            --                OR T26.IdDocFacturacion_RC26_03 = 'NA' THEN  
            --               'La Fecha de Pago debe ser menor o igual al último día natural del periodo que se reporta verificar la Hoja RC_CONT_26_M en la columna RC26_04 Renglón: '  
            --               + CONVERT(VARCHAR(2000), T26.Id_26_M) + '.'  
            --           ELSE  
            --               'La Fecha de Pago debe ser menor o igual al último día natural del periodo que se reporta verificar la Hoja RC_CONT_26_M en la columna RC26_04 Renglón: '  
            --               + CONVERT(VARCHAR(2000), T26.Id_26_M) + ' con el ID del Documento '  
            --               + T26.IdDocFacturacion_RC26_03 + '.'  
            --       END AS [Validaciones]  
            --FROM #TEMPORAL_26_M T26  
            --WHERE DATEDIFF(MONTH, @Mes, FechaPago_RC26_04) >= 1  
            --UNION  
            --4 ________________________________________ UUID no null __________________________________--  
            INSERT INTO #TablaDeValidacionesConciliacion (Validaciones)
            SELECT 'El UUID del CFDI está vacío, Verificar en la Hoja RC_CONT_21_M en la columna RC21_05 Renglón: '  
                   + CONVERT(VARCHAR(2000), T21.Id_21_M) + '.' AS [Validaciones]  
            FROM #TEMPORAL_21_M T21  
            WHERE (  
                      T21.UUID_RC21_05 IS NULL  
                      OR T21.UUID_RC21_05 = 'NÚMERO NO REGISTRADO'  
                  )  
                  AND T21.TipoDocumento_RC21_04 = 'CF'   
			ORDER BY T21.Id_21_M ASC
            ----------------------------  
			INSERT INTO #TablaDeValidacionesConciliacion (Validaciones)
            SELECT  'Los montos en las columnas RC21_22 (Aumentar)/RC21_23 (Disminuir) en la Hoja RC_CONT_21_M Renglón: '  
                   + CONVERT(VARCHAR(2000), T21.Id_21_M) + ' es 0.' AS [Validaciones] 
            FROM #TEMPORAL_21_M T21  
            WHERE (  
                      ISNULL(T21.MontoAumentar_RC21_22,0) = 0
                      AND  ISNULL(T21.MontoDisminuir_RC21_23,0) = 0
                  )  
			ORDER BY T21.Id_21_M ASC
			-------------------------------
			INSERT INTO #TablaDeValidacionesConciliacion (Validaciones)
            SELECT 'El UUID del CFDI está vacío, Verificar en la Hoja RC_CONT_22_M en la columna RC22_04 Renglón: '  
                   + CONVERT(VARCHAR(2000), T22.Id_22_M) + '.' AS [Validaciones]  
            FROM #TEMPORAL_22_M T22  
            WHERE T22.UUID_RC22_04 IS NULL  
			ORDER BY T22.Id_22_M ASC
            ----------------------------  
			INSERT INTO #TablaDeValidacionesConciliacion (Validaciones)
            SELECT CASE  
       WHEN T23.UUID_RC23_02 IS NULL  
                            AND T23.UUID_Relacionado_C23_03 IS NULL THEN  
                           'El UUID del CFDI Principal, así como el UUID del CFDI Relacionado están vacíos, Verificar en la Hoja RC_CONT_23_M en las columnas RC23_02, RC23_03 Renglón: '  
                           + CONVERT(VARCHAR(2000), T23.Id_23_M) + '.'  
                       WHEN T23.UUID_RC23_02 IS NULL THEN  
                           'El UUID del CFDI Principal está vacío, Verificar en la Hoja RC_CONT_23_M en la columna RC23_02 Renglón: '  
                           + CONVERT(VARCHAR(2000), T23.Id_23_M) + '.'  
                       WHEN T23.UUID_Relacionado_C23_03 IS NULL THEN  
                           'El UUID del CFDI Relacionado está vacío, Verificar en la Hoja RC_CONT_23_M en la columna RC23_03 Renglón: '  
                           + CONVERT(VARCHAR(2000), T23.Id_23_M) + '.'  
                   END AS [Validaciones]  
            FROM #TEMPORAL_23_M T23  
            WHERE T23.UUID_RC23_02 IS NULL  
                  OR T23.UUID_Relacionado_C23_03 IS NULL  
            ORDER BY T23.Id_23_M ASC  
            --5 _____________________________ PI y PE si son PPD _____________________________--  
			INSERT INTO #TablaDeValidacionesConciliacion (Validaciones) 
            SELECT CASE  
                       WHEN T21.TipoDocumento_RC21_04 = 'PE' THEN  
                           'El Comprobante de Proveedor en el Extranjero esta Registrado como PPD en vez de PUE, Verificar en la Hoja RC_CONT_21_M en la columna RC21_04 Renglón: '  
                           + CONVERT(VARCHAR(2000), T21.Id_21_M) + '.'  
                       WHEN T21.TipoDocumento_RC21_04 = 'PI' THEN  
                           'El Pedimento de Importación esta Registrado como PPD en vez de PUE, Verificar en la Hoja RC_CONT_21_M en la columna RC21_04 Renglón: '  
                           + CONVERT(VARCHAR(2000), T21.Id_21_M) + '.'  
                   END AS [Validaciones]  
            FROM #TEMPORAL_21_M T21  
            WHERE (  
                      T21.TipoDocumento_RC21_04 = 'PE'  
                      AND T21.MetodoPago_RC21_09 = 'PPD'  
                  )  
                  OR (  
                         T21.TipoDocumento_RC21_04 = 'PI'  
                         AND T21.MetodoPago_RC21_09 = 'PPD'  
                     )             
			ORDER BY T21.Id_21_M ASC
            -- 6________________________ Datos Cuentas Contables Completos _____________________--  
			INSERT INTO #TablaDeValidacionesConciliacion (Validaciones)
            SELECT 'El Número de Cuenta Contable o La Descripción de la Cuenta Contable se encuentra vacío, Verificar en la Hoja RC_CONT_21_M en las columnas RC21_17 o RC21_18 Renglón: '  
                   + CONVERT(VARCHAR(2000), T21.Id_21_M) + '.' AS Validaciones  
            FROM #TEMPORAL_21_M T21  
            WHERE T21.NumCuentContable_RC21_17 IS NULL  
                  OR T21.NumCuentContable_RC21_17 = ''  
                  OR T21.DescCuentaContable_RC21_18 IS NULL  
                  OR T21.DescCuentaContable_RC21_18 = '' 
			ORDER BY T21.Id_21_M ASC
            -- 6________________________ Numero Poliza Contable _____________________--  
			INSERT INTO #TablaDeValidacionesConciliacion (Validaciones) 
            SELECT 'El Número de Póliza Contable se encuentra vacío, Verificar en la Hoja RC_CONT_21_M en la columna RC21_19 Renglón: '  
                   + CONVERT(VARCHAR(2000), T21.Id_21_M) + '.' AS Validaciones  
            FROM #TEMPORAL_21_M T21  
            WHERE T21.NumPoliContable_RC21_19 IS NULL  
                  OR T21.NumPoliContable_RC21_19 = ''
			ORDER BY T21.Id_21_M ASC
            --7 _____________________________ Verificacion del HASH _____________________________--  
            ---------------------HASH en la 22_M  
			INSERT INTO #TablaDeValidacionesConciliacion (Validaciones)
            SELECT CASE 
                       WHEN T22.UUID_RC22_04 IS NULL  
                            OR T22.UUID_RC22_04 = '' THEN  
                           'El Timbre HASH de la Hoja RC_CON_22_M en la columna RC22_03 Renglón: '  
                           + CONVERT(VARCHAR(2000), T22.Id_22_M) + ' se encuentra vacío.'  
                       ELSE  
                           'El Timbre HASH de la Hoja RC_CON_22_M en la columna RC22_03 Renglón: '  
                           + CONVERT(VARCHAR(2000), T22.Id_22_M) + ' se encuentra vacío con el UUID del CFDI: '  
                           + T22.UUID_RC22_04 + '.'  
                   END AS [Validaciones]  
            FROM #TEMPORAL_22_M T22  
            WHERE T22.TimbreHASH_XML_RC22_03 IS NULL  
			ORDER BY T22.Id_22_M ASC
            -------------------HASH en la 24_M
			INSERT INTO #TablaDeValidacionesConciliacion (Validaciones)
            SELECT 'El Timbre HASH de la Hoja RC_CON_24_M en la columna RC24_03 Renglón: '  
                   + CONVERT(VARCHAR(2000), T24.Id_24_M) + ' se encuentra vacío.' AS [Validaciones]  
            FROM #TEMPORAL_24_M T24  
            WHERE T24.TimbreHASH_PDF_RC24_03 IS NULL 
			ORDER BY T24.Id_24_M ASC
            ------------------HASH en la 25_M     
			INSERT INTO #TablaDeValidacionesConciliacion (Validaciones)
            SELECT 'El Timbre HASH de la Hoja RC_CON_25_M en la columna RC25_03 Renglón: '  
                   + CONVERT(VARCHAR(2000), T25.Id_25_M) + ' se encuentra vacío.' AS [Validaciones]  
            FROM #TEMPORAL_25_M T25    
            WHERE T25.TimbreHASH_PDF_RC25_03 IS NULL   
			ORDER BY T25.Id_25_M ASC
            ------------------HASH en la 26_M  
			INSERT INTO #TablaDeValidacionesConciliacion (Validaciones)
            SELECT 'El Timbre HASH de la Hoja RC_CON_26_M en la columna RC26_06 Renglón: '  
                   + CONVERT(VARCHAR(2000), T26.Id_26_M) + ' se encuentra vacío.' AS [Validaciones]  
            FROM #TEMPORAL_26_M T26  
            WHERE T26.TimbreHASH_PDF_RC26_06 IS NULL   
			ORDER BY T26.Id_26_M ASC
            --8 _________________________ RF01_01 (21 al 25) no Null y RC21_00 no null_______________________--  
            INSERT INTO #TablaDeValidacionesConciliacion (Validaciones)
            SELECT 'El Número de Identificación en el Presupuesto Asignado por la CNH están Vacíos, Verificar en la Hoja RC_CONT_21_M en la columna RC21_00 Renglón: '  
                   + CONVERT(VARCHAR(2000), T21.Id_21_M) + '.' AS [Validaciones]  
            FROM #TEMPORAL_21_M T21  
            WHERE T21.NumeroIdentificacion_RC21_00 = ''  
                  OR T21.NumeroIdentificacion_RC21_00 IS NULL  
			ORDER BY T21.Id_21_M ASC
            --9 ____________________  21_22 o 21_23 no mayor a 26_09  __________________--  
            --------------CF-----------------  
			INSERT INTO #TablaDeValidacionesConciliacion (Validaciones)
            SELECT CASE  
                       WHEN T26.IdDocFacturacion_RC26_03 IS NULL  
                            OR T26.IdDocFacturacion_RC26_03 = '' THEN  
                           'La suma de los montos en las columnas RC21_22 (Aumentar)/RC21_23 (Disminuir) en la Hoja RC_CONT_21_M Renglón: '  
                           + CONVERT(VARCHAR(2000), T21.Id_21_M)  
                           + ', no puede ser mayor a su suma de los valores en la columna RC26_09 (Monto Equivalente en Dólares) en la Hoja RC_CONT_26_M Renglón: '  
                           + CONVERT(VARCHAR(2000), T26.Id_26_M) + '.'  
                       WHEN T21.UUID_RC21_05 IS NULL  
                            OR T21.UUID_RC21_05 = '' THEN  
                           'La suma de los montos en las columnas RC21_22 (Aumentar)/RC21_23 (Disminuir) en la Hoja RC_CONT_21_M Renglón: '  
                           + CONVERT(VARCHAR(2000), T21.Id_21_M)  
                           + ', no puede ser mayor a su suma de los valores en la columna RC26_09 (Monto Equivalente en Dólares)  en la Hoja RC_CONT_26_M Renglón: '  
                           + CONVERT(VARCHAR(2000), T26.Id_26_M) + '.'  
                       ELSE  
                           'La suma de los montos en las columnas RC21_22 (Aumentar)/RC21_23 (Disminuir) en la Hoja RC_CONT_21_M Renglón: '  
                           + CONVERT(VARCHAR(2000), T21.Id_21_M) + ' del identificador ' + T26.IdDocFacturacion_RC26_03  
                           + ' no puede ser mayor a su suma de los valores en la columna RC26_09 (Monto Equivalente en Dólares) en la Hoja RC_CONT_26_M Renglón: '  
                           + CONVERT(VARCHAR(2000), T26.Id_26_M) + '.'  
                   END AS [Validaciones]  
            FROM #TEMPORAL_26_M T26  
                INNER JOIN #TEMPORAL_21_M T21  
                    ON T21.UUID_RC21_05 = T26.IdDocFacturacion_RC26_03  
            WHERE T21.TipoDocumento_RC21_04 = 'CF'  
                  AND (  
                          T21.MontoAumentar_RC21_22 > T26.MontoEquivDolare_RC26_09  
                          OR T21.MontoDisminuir_RC21_23 > T26.MontoEquivDolare_RC26_09  
                      )              
            ORDER BY T26.Id_26_M ASC
            ---------------PI--------------  
			INSERT INTO #TablaDeValidacionesConciliacion (Validaciones)
            SELECT CASE  
                       WHEN T26.IdDocFacturacion_RC26_03 IS NULL  
                            OR T26.IdDocFacturacion_RC26_03 = '' THEN  
                           'La suma de los montos en las columnas RC21_22 (Aumentar)/RC21_23 (Disminuir) en la Hoja RC_CONT_21_M Renglón: '  
                           + CONVERT(VARCHAR(2000), T21.Id_21_M)  
                           + ', no puede ser mayor a su suma de los valores en la columna RC26_09 (Monto Equivalente en Dólares)  en la Hoja RC_CONT_26_M Renglón: '  
                           + CONVERT(VARCHAR(2000), T26.Id_26_M) + '.'  
                       WHEN T21.IUC_PI_RC21_06 IS NULL  
                            OR T21.IUC_PI_RC21_06 = '' THEN  
                           'La suma de los montos en las columnas RC21_22 (Aumentar)/RC21_23 (Disminuir) en la Hoja RC_CONT_21_M Renglón: '  
                           + CONVERT(VARCHAR(2000), T21.Id_21_M)  
                           + ', no puede ser mayor a su suma de los valores en la columna RC26_09 (Monto Equivalente en Dólares)  en la Hoja RC_CONT_26_M Renglón: '  
                           + CONVERT(VARCHAR(2000), T26.Id_26_M) + '.'  
                       ELSE  
                           'La suma de los montos en las columnas RC21_22 (Aumentar)/RC21_23 (Disminuir) en la Hoja RC_CONT_21_M Renglón: '  
                           + CONVERT(VARCHAR(2000), T21.Id_21_M) + ' del identificador ' + T26.IdDocFacturacion_RC26_03  
                           + ' no puede ser mayor a su suma de los valores en la columna RC26_09 (Monto Equivalente en Dólares)  en la Hoja RC_CONT_26_M Renglón: '  
                           + CONVERT(VARCHAR(2000), T26.Id_26_M) + '.'  
                   END AS [Validaciones]  
            FROM #TEMPORAL_26_M T26  
                INNER JOIN #TEMPORAL_21_M T21  
                    ON T21.IUC_PI_RC21_06 = T26.IdDocFacturacion_RC26_03  
		   WHERE T21.TipoDocumento_RC21_04 = 'PI'  
                  AND (  
                          T21.MontoAumentar_RC21_22 > T26.MontoEquivDolare_RC26_09  
                          OR T21.MontoDisminuir_RC21_23 > T26.MontoEquivDolare_RC26_09  
                      )  
            ORDER BY T26.Id_26_M ASC  
            --------------------PE-----------------------  
			INSERT INTO #TablaDeValidacionesConciliacion (Validaciones)
            SELECT CASE  
                       WHEN T26.IdDocFacturacion_RC26_03 IS NULL  
                            OR T26.IdDocFacturacion_RC26_03 = '' THEN  
                           'La suma de los montos en las columnas RC21_22 (Aumentar)/RC21_23 (Disminuir) en la Hoja RC_CONT_21_M Renglón: '  
                           + CONVERT(VARCHAR(2000), T21.Id_21_M)  
                           + ', no puede ser mayor a su suma de los valores en la columna RC26_09 (Monto Equivalente en Dólares) en la Hoja RC_CONT_26_M del Renglón: '  
                           + CONVERT(VARCHAR(2000), T26.Id_26_M) + '.'  
                       WHEN T21.IUC_PE_RC21_07 IS NULL  
                            OR T21.IUC_PE_RC21_07 = '' THEN  
                           'La suma de los montos en las columnas RC21_22 (Aumentar)/RC21_23 (Disminuir) en la Hoja RC_CONT_21_M Renglón: '  
                           + CONVERT(VARCHAR(2000), T21.Id_21_M)  
                           + ', no puede ser mayor a su suma de los valores en la columna RC26_09 (Monto Equivalente en Dólares) en la Hoja RC_CONT_26_M del Renglón: '  
                           + CONVERT(VARCHAR(2000), T26.Id_26_M) + '.'  
                       ELSE  
                           'La suma de los montos en las columnas RC21_22 (Aumentar)/RC21_23 (Disminuir) en la Hoja RC_CONT_21_M Renglón: '  
                           + CONVERT(VARCHAR(2000), T21.Id_21_M) + ' del identificador ' + T26.IdDocFacturacion_RC26_03  
                           + ' no puede ser mayor a su suma de los valores en la columna RC26_09 (Monto Equivalente en Dólares) en la Hoja RC_CONT_26_M del Renglón: '  
                           + CONVERT(VARCHAR(2000), T26.Id_26_M) + '.'  
                   END AS [Validaciones]  
            FROM #TEMPORAL_26_M T26  
                INNER JOIN #TEMPORAL_21_M T21  
                    ON T21.IUC_PE_RC21_07 = T26.IdDocFacturacion_RC26_03  
            WHERE T21.TipoDocumento_RC21_04 = 'PE'  
                  AND (  
                          T21.MontoAumentar_RC21_22 > T26.MontoEquivDolare_RC26_09  
                          OR T21.MontoDisminuir_RC21_23 > T26.MontoEquivDolare_RC26_09  
                      ) 
			ORDER BY T26.Id_26_M ASC
            --10_____________________________ Archivos No nulos o NOTA:Falta ingresar archivo PDF o XML ______________________________________--  
            ------------RC_CONT_22_M-------  
			INSERT INTO #TablaDeValidacionesConciliacion (Validaciones)
            SELECT CASE  
                       WHEN T22.UUID_RC22_04 IS NOT NULL THEN  
                           'No se encuentra archivo XML verificar en la Hoja RC_CONT_22_M en la columna RC22_02 Renglón: '  
                           + CONVERT(VARCHAR(2000), T22.Id_22_M) + ' referente a el UUID: ' + T22.UUID_RC22_04 + '.'  
                       ELSE  
                           'No se encuentra archivo XML verificar en la Hoja RC_CONT_22_M en la columna RC22_02 Renglón: '  
                           + CONVERT(VARCHAR(2000), T22.Id_22_M) + '.'  
                   END AS [Validaciones]  
            FROM #TEMPORAL_22_M T22  
            WHERE T22.NomArchivo_XML_RC22_02 IS NULL  
                  OR T22.NomArchivo_XML_RC22_02 = ''  
            ORDER BY T22.Id_22_M ASC  
            -------------RC_CONT_24_M------  
			INSERT INTO #TablaDeValidacionesConciliacion (Validaciones)
            SELECT CASE  
                       WHEN T24.TimbreHASH_PDF_RC24_03 IS NOT NULL THEN  
                           'Falta Ingresar Archivo PDF verificar Hoja RC_CONT_24_M en la columna RC24_02 Renglón: '  
                           + CONVERT(VARCHAR(2000), T24.Id_24_M) + ' referente a el Timbre HASH: '  
                           + T24.TimbreHASH_PDF_RC24_03 + '.'  
                       ELSE  
                           'Falta Ingresar Archivo PDF verificar Hoja RC_CONT_24_M en la columna RC24_02 Renglón: '  
                           + CONVERT(VARCHAR(2000), T24.Id_24_M) + '.'  
                   END AS [Validaciones]  
            FROM #TEMPORAL_24_M T24  
            WHERE T24.NomArchivo_PDF_RC24_02 IS NULL  
                  OR T24.NomArchivo_PDF_RC24_02 = '' 
            ORDER BY T24.Id_24_M ASC  
            -----------RC_CONT_26_M--------  
			INSERT INTO #TablaDeValidacionesConciliacion (Validaciones)
            SELECT CASE  
                       WHEN T26.IdDocFacturacion_RC26_03 IS NULL  
                            OR T26.IdDocFacturacion_RC26_03 = 'NA' THEN  
                           'Falta Ingresar Archivo PDF verificar Hoja RC_CONT_26_M en la columna RC26_05 Renglón: '  
                           + CONVERT(VARCHAR(2000), T26.Id_26_M) + '.'  
                       ELSE  
                           'Falta Ingresar Archivo PDF verificar Hoja RC_CONT_26_M en la columna RC26_05 Renglón: '  
                           + CONVERT(VARCHAR(2000), T26.Id_26_M) + ' referente al ID: ' + T26.IdDocFacturacion_RC26_03  
                           + ' del Documento de Facturación Pagado.'  
                   END AS [Validaciones]  
            FROM #TEMPORAL_26_M T26  
            WHERE T26.NomArchivo_PDF_RC26_05 = 'NOTA:Falta ingresar archivo PDF'  
            ORDER BY T26.Id_26_M ASC  
            --11 ___________________________________ Folio 22_04, 22_11 sean iguales a 26_03, 26_02___________________________________________--  
			INSERT INTO #TablaDeValidacionesConciliacion (Validaciones)
			SELECT 'La Forma de Pago en la Hoja RC_CONT_22_M en la columna RC22_11 Renglón: '  
                   + CONVERT(VARCHAR(2000), T22.Id_22_M) + ' esta como "' + T22.FormPago_RC22_11  
                   + '" y en la Hoja RC_CONT_26_M en la columna RC26_02 Renglón: '  
                   + CONVERT(VARCHAR(2000), T26.Id_26_M) + ' esta como "' + T26.FormaPago_RC26_02 + '".'  
            FROM #TEMPORAL_26_M T26  
                INNER JOIN #TEMPORAL_22_M T22  
                    ON T22.UUID_RC22_04 = T26.IdDocFacturacion_RC26_03  
            WHERE T22.FormPago_RC22_11 <> T26.FormaPago_RC26_02  
            ORDER BY T22.Id_22_M ASC  
            --12 ___________________________________ UUID Repetido___________________________________________--  
			INSERT INTO #TablaDeValidacionesConciliacion (Validaciones)
			SELECT 'Verificar la Hoja RC_CONT_22_M en la columna RC22_04 Renglones: '  
                   + STUFF(  
                     (  
                         SELECT DISTINCT  
                             ', ' + CONVERT(VARCHAR(2000), T22A.Id_22_M)  
                         FROM #TEMPORAL_22_M T22A  
                         WHERE T22A.UUID_RC22_04 = T22.UUID_RC22_04  
                         FOR XML PATH('')  
                     ),  
                     1,  
                     2,  
                     ''  
                          ) + ' ya que el UUID ' + T22.UUID_RC22_04 + ' se repite.'  
            FROM #TEMPORAL_22_M T22  
            GROUP BY T22.UUID_RC22_04  
            HAVING COUNT(T22.UUID_RC22_04) >= 2 
            --14 ___________________________________   _______________________________--
			INSERT INTO #TablaDeValidacionesConciliacion (Validaciones)
            SELECT CASE  
                       WHEN COUNT(T26.TimbreHASH_PDF_RC26_06) > 1 THEN  
                ('Verificar en Hoja RC_CONT_26_M en la columna RC26_05 en los renglones '  
                 + STUFF(  
                   (  
                       SELECT DISTINCT  
                           ', ' + CONVERT(VARCHAR(2000), T26A.Id_26_M)  
                       FROM #TEMPORAL_26_M T26A  
                       WHERE T26A.TimbreHASH_PDF_RC26_06 = T26.TimbreHASH_PDF_RC26_06  
                       FOR XML PATH('')  
                   ),  
                   1,  
                   2,  
                   ''  
                        ) + ' ya que los comprobantes de las formas de pago comparte el mismo HASH: '  
                 + T26.TimbreHASH_PDF_RC26_06 + ' en la columna RC26_06.'  
                )  
                   END  
            FROM #TEMPORAL_26_MContTemp T26C  
                JOIN #TEMPORAL_26_M T26  
                    ON T26C.TimbreHASH = T26.TimbreHASH_PDF_RC26_06  
          GROUP BY T26.TimbreHASH_PDF_RC26_06  
		  
		  SELECT Validaciones FROM #TablaDeValidacionesConciliacion
		  WHERE ISNULL([Validaciones], '') <> '';		
    END;  
	
    IF (@Plantilla = 'CGI_2022')  
    BEGIN  
		SELECT  IdContratista_RF_00,  
            IdContrato_RI_00,  
            NumeroContrato_RF01_01,  
            NumeroIdentificacion_RC21_00,  
            MesReporte_RC21_01,  
            AnioReporte_RC21_02,  
            NumeroConsecutivo_RC21_03,  
            TipoDocumento_RC21_04,  
            UUID_RC21_05,  
            IUC_PI_RC21_06,  
            IUC_PE_RC21_07,  
            TipoComprobante_RC21_08,  
            MetodoPago_RC21_09,  
            Actividad_RC21_10,  
            SubActividad_RC21_11,  
            Tarea_RC21_12,  
            CASE WHEN CostAtribAdminGral_RC21_13 IS NULL THEN NULL WHEN CostAtribAdminGral_RC21_13 = 1 THEN 1 ELSE 0 END AS CostAtribAdminGral_RC21_13,  
            Campo_RC21_14,  
            Yacimiento_RC21_15,  
            Pozo_RC21_16,  
            NumCuentContable_RC21_17,  
            DescCuentaContable_RC21_18,  
            NumPoliContable_RC21_19,  
            ConcepOp_RC21_20,  
            GastoOpInver_RC21_21,  
            MontoAumentar_RC21_22,  
            MontoDisminuir_RC21_23,  
            ClavaMoneda_RC21_24,  
            TipCamConvetUSD_RC21_25,  
            TipoOpercion_RC21_26,  
            RegistroConAjuste_RC21_27,  
            AsociadoIncrementoPMT_RC21_28   
			FROM #TEMPORAL_21_M
			ORDER BY #TEMPORAL_21_M.Id_21_M ASC
	END
	ELSE
	BEGIN
			SELECT  IdContratista_RF_00,  
            IdContrato_RI_00,  
            NumeroContrato_RF01_01,  
            NumeroIdentificacion_RC21_00,  
            MesReporte_RC21_01,  
            AnioReporte_RC21_02,  
            NumeroConsecutivo_RC21_03,  
            TipoDocumento_RC21_04,  
            UUID_RC21_05,  
            IUC_PI_RC21_06,  
            IUC_PE_RC21_07,  
            TipoComprobante_RC21_08,  
            MetodoPago_RC21_09,  
            Actividad_RC21_10,  
            SubActividad_RC21_11,  
            Tarea_RC21_12,  
            CASE WHEN CostAtribAdminGral_RC21_13 IS NULL THEN NULL WHEN CostAtribAdminGral_RC21_13 = 1 THEN 1 ELSE 0 END AS CostAtribAdminGral_RC21_13,  
            Campo_RC21_14,  
            Yacimiento_RC21_15,  
            Pozo_RC21_16,  
            NumCuentContable_RC21_17,  
            DescCuentaContable_RC21_18,  
            NumPoliContable_RC21_19,  
            ConcepOp_RC21_20,  
            GastoOpInver_RC21_21,  
            MontoAumentar_RC21_22,  
            MontoDisminuir_RC21_23,  
            ClavaMoneda_RC21_24,  
            TipCamConvetUSD_RC21_25,  
            TipoOpercion_RC21_26 
			FROM #TEMPORAL_21_M
			ORDER BY #TEMPORAL_21_M.Id_21_M ASC
	END
	SELECT	IdContratista_RF_00,  
			IdContrato_RI_00,  
			NumeroContrato_RF01_01,  
			MesReporte_RC21_01,  
			AnioReporte_RC21_02,  
			NomArchivo_XML_RC22_02,  
			TimbreHASH_XML_RC22_03,  
			UUID_RC22_04,  
			TipoComprobante_RC22_05,  
			MetPago_RC22_06,  
			MontoTotal_RC22_07,  
			Subtotal_RC22_08,  
			MontoLiquida_RC22_09,  
			NumParcialidad_RC22_10,  
			FormPago_RC22_11,  
			FechaExpedicion_RC22_12,  
			RFC_Emisor_RC22_13,  
			LugarExpedicion_RC22_14,  
			RFC_Receptor_RC22_15,  
			ClaveMoneda_RC22_16,  
			ClasDocSoporte_RC22_17 
			FROM #TEMPORAL_22_M
			ORDER BY #TEMPORAL_22_M.Id_22_M ASC

	SELECT  IdContratista_RF_00,  
			IdContrato_RI_00,  
			NumeroContrato_RF01_01,  
			MesReporte_RC23_00,  
			AnioReporte_RC23_01,  
			UUID_RC23_02,  
			UUID_Relacionado_C23_03,  
			TipoRelacion_RC23_04,  
			NumParcialidad_RC23_05  
			FROM #TEMPORAL_23_M
			ORDER BY #TEMPORAL_23_M.Id_23_M

	SELECT  IdContratista_RF_00,  
			IdContrato_RI_00,  
			NumeroContrato_RF01_01,  
			MesReporte_RC24_00,  
			AnioReporte_RC24_01,  
			NomArchivo_PDF_RC24_02,  
			TimbreHASH_PDF_RC24_03,  
			IDPedimentoImportacion_RC24_04,  
			AcuseElecValidacion_RC24_05,  
			ValorDolares_RC24_06,  
			PrecioPagado_ValorComercial_RC24_07,  
			ClavePedimento_RC24_08,  
			FormaPago_RC24_09,  
			FechaOriginal_RC24_10,  
			Regimen_RC24_11,  
			RFC_Importador_RC24_12,  
			AduanaES_RC24_13,  
			IdFiscal_RC24_14,  
			RazonSocialProv_RC24_15,  
			NumFactura_RC24_16,  
			FechaFactura_RC24_17,  
			ValMontFact_RC24_18,  
			ValDolares_RC24_19,  
			ClasDocSoporte_RC24_20  
			FROM #TEMPORAL_24_M
			ORDER BY #TEMPORAL_24_M.Id_24_M ASC

	SELECT	IdContratista_RF_00,  
			IdContrato_RI_00,  
			NumeroContrato_RF01_01,  
			MesReporte_RC25_00,  
			AnioReporte_RC25_01,  
			NomArchivo_PDF_RC25_02,  
			TimbreHASH_PDF_RC25_03,  
			IdDocFacturacion_RC25_04,  
			FolioCompExtranjero_RC25_05,  
			ImporteTotalAntesImpuestos_RC25_06,  
			FormaPago_RC25_07,  
			FechaPago_RC25_08,  
			RFC_Importador_RC25_09,  
			RZImportador_RC25_10,  
			RZEmisorCompExtranjero_RC25_11,  
			IdFiscal_RC25_12,  
			NumFactura_RC25_13,  
			FechaFactura_RC25_14,  
			ValMontFact_RC25_15,  
			ValDolares_RC25_16,  
			ClasDocSoporte_RC25_17 
			FROM #TEMPORAL_25_M
			ORDER BY #TEMPORAL_25_M.Id_25_M ASC

	SELECT	IdContratista_RF_00,  
			IdContrato_RI_00,  
			MesReporte_RC26_00,  
			AnioReporte_RC26_01,  
			FormaPago_RC26_02,  
			IdDocFacturacion_RC26_03,  
			FechaPago_RC26_04,  
			NomArchivo_PDF_RC26_05,  
			TimbreHASH_PDF_RC26_06,  
			MontoPagado_RC26_07,  
			ClaveMonedaFactura_RC26_08,  
			MontoEquivDolare_RC26_09,  
			TipoCambio_RC26_10,  
			Beneficiario_RC26_11,  
			ClasDocSoporte_RC26_12 
			FROM #TEMPORAL_26_M
			ORDER BY #TEMPORAL_26_M.Id_26_M ASC
END; 
