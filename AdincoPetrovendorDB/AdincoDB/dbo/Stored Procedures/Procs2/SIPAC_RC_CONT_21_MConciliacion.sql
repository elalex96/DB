IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SIPAC_RC_CONT_21_MConciliacion'
)
    DROP PROCEDURE SIPAC_RC_CONT_21_MConciliacion;
GO

CREATE PROCEDURE [dbo].[SIPAC_RC_CONT_21_MConciliacion]  
    @Contrato      INT,  
    @IdPresupuesto INT          = 0,  
    @Plantilla     VARCHAR(150) = ''  
AS  
    BEGIN  
        SET NOCOUNT ON;  
    	
		DECLARE @Aprobado INT = 10004,
		@TipoFactura INT = 1,
		@PESO INT = 1,
		@DOLAR INT = 2,
		@TipoComplementoPago INT = 6,
		@TipoPedimentoImportacion INT = 2,
		@TipoComprobanteExtranjero INT = 3

        /*Calcular montos pagados*/  
        IF OBJECT_ID('tempdb..#Facturas', 'U') IS NOT NULL  
            DROP TABLE #Facturas;  
  
        IF OBJECT_ID('tempdb..#MontosTotalTransferenciaPPD', 'U') IS NOT NULL  
            DROP TABLE #MontosTotalTransferenciaPPD;  
  
        IF OBJECT_ID('tempdb..#MontosTotalTransferenciaPUE', 'U') IS NOT NULL  
            DROP TABLE #MontosTotalTransferenciaPUE;  
  
        IF OBJECT_ID('tempdb..#MontosConvertidosPedimentosCom', 'U') IS NOT NULL  
            DROP TABLE #MontosConvertidosPedimentosCom;  
  
        IF OBJECT_ID('tempdb..#uuidNoReportar', 'U') IS NOT NULL  
            DROP TABLE #uuidNoReportar;  
  
        IF OBJECT_ID('tempdb..#SumaDePagosDolares', 'U') IS NOT NULL  
            DROP TABLE #SumaDePagosDolares;  
  
        IF OBJECT_ID('tempdb..#ResultadosGastos', 'U') IS NOT NULL  
            DROP TABLE #ResultadosGastos;  
  
        IF OBJECT_ID('tempdb..#SumaDePagosDolaresBase', 'U') IS NOT NULL  
            DROP TABLE #SumaDePagosDolaresBase;  
  
        /*Omitir facturas en la hoja 21*/  
        /*CREACIONES DE TABLAS*/  
        CREATE TABLE #uuidNoReportar (UUID VARCHAR(2000));  
  
        CREATE TABLE #MontosTotalTransferenciaPUE  
            (  
                IdRegistro      INT,  
                UUID            VARCHAR(2000),  
                Idfactura       INT,  
                MontoRegistro   FLOAT,  
                TipoComprobante NVARCHAR(50),  
                RC2122          FLOAT,  
                MetodoPago      NVARCHAR(50),  
                TCD             FLOAT,  
                FechaTCD        DATE,  
                IdMoneda        INT  
            );  
  
        CREATE TABLE #Facturas  
            (  
                IdRegistro      INT,  
                UUID            VARCHAR(2000),  
                Idfactura       INT,  
                MontoRegistro   FLOAT,  
                TipoComprobante VARCHAR(50),  
                RC2122          FLOAT,  
                MetodoPago      VARCHAR(50),  
                Fecha           DATETIME,  
                IdMoneda        INT  
            );  
  
        CREATE TABLE #MontosTotalTransferenciaPPD  
            (  
                IdFacturaCP     INT,  
                UUIDCP          VARCHAR(2000),  
                FormaPagoCP     VARCHAR(50),  
                MontoCP         FLOAT,  
                TipoCambioCP    FLOAT,  
                MonedaCP        VARCHAR(50),  
                MontoPesos      FLOAT,  
                MontoDolares    FLOAT,  
                TipoComprobante VARCHAR(50),  
                MontoRegistro   FLOAT,  
                IdRegistro      INT  
            );  
  
        CREATE TABLE #MontosConvertidosPedimentosCom  
            (  
                IdRegistro             INT,  
                IdPedimentoComprobante INT,  
                MontoRegistro          FLOAT,  
                RC2122                 FLOAT,  
                TCD                    FLOAT  
            );  
  
        CREATE TABLE #SumaDePagosDolares  
            (  
                UUID            VARCHAR(2000),  
                Idfactura       INT,  
                TipoComprobante VARCHAR(50),  
                MontoDolares    FLOAT,  
                MetodoPago      VARCHAR(50),  
                TipoCambio      FLOAT,  
                Fecha           DATE,  
                IdMoneda        INT  
            )  
  
        CREATE TABLE #SumaDePagosDolaresBase  
            (  
                UUID            VARCHAR(2000),  
                Idfactura       INT,  
                TipoComprobante VARCHAR(50),  
                MontoDolares    FLOAT,  
                MetodoPago      VARCHAR(50),  
                TipoCambio      FLOAT,  
                Fecha           DATE,  
                IdMoneda        INT,  
                MonedaTran      INT,  
                IdTransferencia INT,  
            )  
  
        CREATE TABLE #ResultadosGastos  
            (  
                [RF_00]   VARCHAR(30),  
                [RI_00]   VARCHAR(100),  
                [RF01_01] VARCHAR(2000),  
                [RC21_00] VARCHAR(100),  
                [RC21_01] INT          NULL,  
                [RC21_02] INT          NULL,  
                [RC21_03] INT          NULL,  
                [RC21_04] VARCHAR(30),  
                [RC21_05] VARCHAR(2000),  
                [RC21_06] VARCHAR(2000),  
                [RC21_07] VARCHAR(2000),  
                [RC21_08] VARCHAR(30),  
                [RC21_09] VARCHAR(100),  
                [RC21_10] VARCHAR(100),  
                [RC21_11] VARCHAR(100),  
                [RC21_12] VARCHAR(100),  
                [RC21_13] INT          NULL,  
                [RC21_14] VARCHAR(2000),  
                [RC21_15] VARCHAR(2000),  
                [RC21_16] VARCHAR(2000),  
                [RC21_17] VARCHAR(2000),  
                [RC21_18] VARCHAR(2000),  
                [RC21_19] VARCHAR(2000),  
                [RC21_20] VARCHAR(2000),  
                [RC21_21] INT          NULL,  
                [RC21_22] FLOAT        NULL,  
                [RC21_23] FLOAT        NULL,  
                [RC21_24] VARCHAR(10),  
                [RC21_25] FLOAT        NULL,  
                [RC21_26] INT          NULL,  
                [RC21_27] INT          NULL,  
                [RC21_28] INT          NULL  
            );  
  
        ------------------------------------    
        DECLARE  
            @GastosConFacturaPPD INT,  
            @GastosConFacturaPUE INT,  
            @GastosConPedCom     INT,  
            @CuentaDeRegistros   INT = 0;  
  
    
                INSERT INTO #uuidNoReportar  
                    (  
                        UUID  
                    )  
                VALUES  
                    (  
                        '091A3242-EF0F-444A-A5C1-3D7D50247D3B'  
                    ),  
                    (  
                        '775E782A-9493-3D40-9B24-E1604A865A0F'  
                    ),  
                    (  
                        '78BB3869-8091-B049-98B4-1238E15E7BDA'  
                    ),  
                    (  
                        'A6344C73-4C5A-EA4A-B2F8-3378CDA24C17'  
                    );  
            
                INSERT INTO #uuidNoReportar  
                    (  
                        UUID  
                    )  
                VALUES  
                    (  
                        '9A159442-52BC-1E49-8190-D020953CE967'  
                    );  
            
                INSERT INTO #uuidNoReportar  
                    (  
                        UUID  
                    )  
                VALUES  
                    (  
                        '78CA2E37-22C0-408C-8E94-105C7388A704'  
                    ),  
                    (  
                        '30EFEC90-471E-434A-87CF-EFFEEE7C48C1'  
                    );  
           
                INSERT INTO #uuidNoReportar  
                    (  
                        UUID  
                    )  
                VALUES  
                    (  
                        'D515F4A9-244C-422E-A2B1-11B234039715'  
                    ),  
                    (  
                        '1091E714-CC8E-46B8-8421-37470C285BAC'  
                    ),  
                    (  
                        '95AB6B55-C312-4CAF-9A9E-BD7E7A2124AB'  
                    ),  
                    (  
                        '10FDC8FB-DEBB-4BD5-8C10-6B51E61B5FE6'  
                    );  


        INSERT INTO #Facturas  
            (  
                IdRegistro,  
                UUID,  
                Idfactura,  
                MontoRegistro,  
                TipoComprobante,  
                RC2122,  
                MetodoPago,  
                Fecha,  
                IdMoneda  
            )  
                    SELECT  
                        CO_Registro.IdRegistro,  
                        ISNULL(FI_Factura.UUID, 'NÚMERO NO REGISTRADO') AS UUID,  
                        FI_Factura.IdFactura,  
                        CO_Registro.MontoRegistro,  
                        CASE  
                            WHEN FI_Factura.TipoComprobante LIKE '%ingreso%'  
                                 OR FI_Factura.TipoComprobante LIKE 'I%'  
                                THEN 'I'  
                            WHEN (FI_Factura.TipoComprobante) LIKE '%egreso%'  
                                 OR FI_Factura.TipoComprobante LIKE 'E%'  
                                THEN 'E'  
                            WHEN (FI_Factura.TipoComprobante) LIKE '%traslado%'  
                                 OR FI_Factura.TipoComprobante LIKE 'T%'  
                                THEN 'T'  
                            WHEN (FI_Factura.TipoComprobante) LIKE '%nómina%'  
                                 OR FI_Factura.TipoComprobante LIKE 'N%'  
                                THEN 'N'  
                            WHEN (FI_Factura.TipoComprobante) LIKE '%pago%'  
                                 OR FI_Factura.TipoComprobante LIKE 'P%'  
                                THEN 'P'  
                            ELSE  
                                'NA'  
                        END                                             AS TipoComprobante,  
                        SUM(   CASE    
								   WHEN ISNULL(CO_TipoCambioDiario.TipoCambio, 0) = 0  
									   THEN 0
                                   WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0  
                                       THEN CAST(ROUND(  
                                                          (ISNULL(CO_Registro.MontoRegistro, 0)  
                                                           / CO_TipoCambioDiario.TipoCambio  
                                                          ), 2  
                                                      ) AS DECIMAL(15, 2))  
                                   ELSE  
                                       0  
                               END  
                           )                                            AS [RC21_22],  
                        CASE  
                            WHEN FI_Factura.MetodoPago LIKE '%exhibi%'  
                                 OR FI_Factura.MetodoPago LIKE '%PUE%'  
                                 OR FI_Factura.FormaPago LIKE '%exhibi%'  
                                 OR FI_Factura.FormaPago LIKE '%PUE%'  
                                THEN 'PUE'  
                            WHEN FI_Factura.MetodoPago LIKE '%parcia%'  
                                 OR FI_Factura.MetodoPago LIKE '%dife%'  
                                 OR FI_Factura.MetodoPago LIKE '%PPD%'  
                                 OR FI_Factura.FormaPago LIKE '%parcia%'  
                                 OR FI_Factura.FormaPago LIKE '%dife%'  
                                 OR FI_Factura.FormaPago LIKE '%PPD%'  
                                THEN 'PPD'  
                            WHEN FI_Factura.TipoComprobante = 'P'  
                                THEN 'PPD'  
                        END                                             AS MetodoPago,  
                        FI_Factura.Fecha,  
                        FI_Factura.IdMoneda  
                    FROM  
						dbo.CO_Contrato WITH (NOLOCK)
						INNER JOIN dbo.CO_Servicio WITH (NOLOCK) 
							ON CO_Contrato.IdContrato = CO_Servicio.IdContrato
							AND CO_Servicio.IdContrato = @Contrato 
						INNER JOIN dbo.CO_LineaPresupuestoMes WITH (NOLOCK) 
							ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
                        INNER JOIN dbo.CO_Registro WITH (NOLOCK)  
							ON CO_Registro.IdEstado = @Aprobado
							AND CO_Registro.CvTipoDocFacturacion = @TipoFactura
							AND CO_LineaPresupuestoMes.IdLineaPresupuestoMes = CO_Registro.IdPrograma
                        INNER JOIN dbo.FI_Factura WITH (NOLOCK)  
                                ON CO_Registro.IdFactura = FI_Factura.IdFactura     
                        LEFT JOIN  
                            dbo.CO_TipoCambioDiario WITH (NOLOCK)  
                                ON CO_TipoCambioDiario.IdMoneda = FI_Factura.IdMoneda  
                                   AND DAY(CO_TipoCambioDiario.Fecha) = DAY(FI_Factura.Fecha)  
                                   AND MONTH(CO_TipoCambioDiario.Fecha) = MONTH(FI_Factura.Fecha)  
                                   AND YEAR(CO_TipoCambioDiario.Fecha) = YEAR(FI_Factura.Fecha)  
                    WHERE  
                        CO_Contrato.IdContrato = @Contrato   
                        AND CO_Registro.IdEstado = @Aprobado  
                        AND CO_Registro.CvTipoDocFacturacion = @TipoFactura  
                        AND ISNULL(CONVERT(INT, FI_Factura.ProcesadoSIPAC), 0) = 0  
                        AND CO_Servicio.NombreServicio NOT LIKE '%No elegibles%'  
                        AND CO_LineaPresupuestoMes.IdPresupuesto = CASE  
                                                                       WHEN @IdPresupuesto = 0  
                                                                           THEN CO_LineaPresupuestoMes.IdPresupuesto  
                                                                       ELSE  
                                                                           @IdPresupuesto  
                                                                   END  
                    GROUP BY  
                        CO_Registro.IdRegistro,  
                        ISNULL(FI_Factura.UUID, 'NÚMERO NO REGISTRADO'),  
                        FI_Factura.IdFactura,  
                        CO_Registro.MontoRegistro,  
                        CASE  
                            WHEN FI_Factura.TipoComprobante LIKE '%ingreso%'  
                                 OR FI_Factura.TipoComprobante LIKE 'I%'  
                                THEN 'I'  
                            WHEN (FI_Factura.TipoComprobante) LIKE '%egreso%'  
                                 OR FI_Factura.TipoComprobante LIKE 'E%'  
                                THEN 'E'  
                            WHEN (FI_Factura.TipoComprobante) LIKE '%traslado%'  
                                 OR FI_Factura.TipoComprobante LIKE 'T%'  
                                THEN 'T'  
                            WHEN (FI_Factura.TipoComprobante) LIKE '%nómina%'  
                                 OR FI_Factura.TipoComprobante LIKE 'N%'  
                                THEN 'N'  
                            WHEN (FI_Factura.TipoComprobante) LIKE '%pago%'  
                                 OR FI_Factura.TipoComprobante LIKE 'P%'  
                                THEN 'P'  
                            ELSE  
                                'NA'  
                        END,  
                        CASE  
                            WHEN FI_Factura.MetodoPago LIKE '%exhibi%'  
                                 OR FI_Factura.MetodoPago LIKE '%PUE%'  
                                 OR FI_Factura.FormaPago LIKE '%exhibi%'  
                                 OR FI_Factura.FormaPago LIKE '%PUE%'  
                                THEN 'PUE'  
                            WHEN FI_Factura.MetodoPago LIKE '%parcia%'  
                                 OR FI_Factura.MetodoPago LIKE '%dife%'  
                                 OR FI_Factura.MetodoPago LIKE '%PPD%'  
                                 OR FI_Factura.FormaPago LIKE '%parcia%'  
                                 OR FI_Factura.FormaPago LIKE '%dife%'  
                                 OR FI_Factura.FormaPago LIKE '%PPD%'  
                                THEN 'PPD'  
                            WHEN FI_Factura.TipoComprobante = 'P'  
								THEN 'PPD'  
                        END,  
                        FI_Factura.Fecha,  
                        FI_Factura.IdMoneda;
  
  
        /*Facturas Con Tipo de Cambio de Transferencia*/  
        INSERT INTO #MontosTotalTransferenciaPPD  
            (  
                IdFacturaCP,  
                UUIDCP,  
                FormaPagoCP,  
                MontoCP,  
                TipoCambioCP,  
                MonedaCP,  
                MontoPesos,  
                MontoDolares,  
                TipoComprobante,  
                MontoRegistro,  
                IdRegistro  
            )  
                    SELECT  
                        FI_Factura.IdFactura                                                             AS IdFacturaCP,  
                        FI_Factura.UUID                                                                  AS UUIDCP,  
                        FI_ComplementoDePago.FormaDePagoP                                                AS FormaPagoCP,  
                        SUM(FI_CPDocRelacionado.ImpPagado)                                               AS MontoCP,  
                        ISNULL(CO_TipoCambioDiario.TipoCambio, 0)                                                   AS TipoCambioCP,  
                        FI_ComplementoDePago.MonedaP                                                     AS MonedaCP,  
                        CAST(SUM(FI_CPDocRelacionado.ImpPagado) AS DECIMAL(15, 2))                       AS MontoPesos,  
                        CAST(SUM(   CASE  
                                        WHEN PV_TipoMoneda.IdMoneda = @DOLAR
											THEN FI_CPDocRelacionado.ImpPagado  
                                        WHEN ISNULL(CO_TipoCambioDiario.TipoCambio, 0) = 0  
                                            THEN 0 
                                        WHEN PV_TipoMoneda.IdMoneda = @PESO  
                                            THEN FI_CPDocRelacionado.ImpPagado / CO_TipoCambioDiario.TipoCambio 
										WHEN PV_TipoMoneda.IdMoneda NOT IN (@PESO, @DOLAR)
											THEN FI_CPDocRelacionado.ImpPagado / CO_TipoCambioDiario.TipoCambio 
                                    END  
                                ) AS DECIMAL(15, 2))                                                     AS MontoDolares,  
                        FI_Factura.TipoComprobante,  
						 CAST(
						 CASE    
                            WHEN ISNULL(CO_TipoCambioDiario.TipoCambio, 0) = 0  
                                THEN 0
								ELSE #Facturas.MontoRegistro / CO_TipoCambioDiario.TipoCambio 
							END AS DECIMAL(15, 2)
						) AS MontoRegistro, 
                        #Facturas.IdRegistro  
                    FROM  #Facturas 
						INNER JOIN dbo.FI_Factura FCPDR WITH (NOLOCK) 
							ON #Facturas.IdFactura = FCPDR.IdFactura
								AND #Facturas.MetodoPago = 'PPD'
						INNER JOIN  
                            dbo.FI_CPDocRelacionado WITH (NOLOCK)  
                                ON FCPDR.UUID = FI_CPDocRelacionado.IdDocumento 
						INNER JOIN  
                            dbo.FI_ComplementoDePago WITH (NOLOCK)  
                                ON FI_CPDocRelacionado.IdComplementoDePago = FI_ComplementoDePago.IdComplementoDePago
						INNER JOIN  
                            dbo.FI_TransferFactura WITH (NOLOCK)  
                                ON FI_ComplementoDePago.IdFactura = FI_TransferFactura.IdFactura  
                                   AND FI_TransferFactura.CvTipoDocFacturacion = @TipoComplementoPago  
						INNER JOIN  
                            dbo.FI_Factura WITH (NOLOCK)  
                                ON FI_ComplementoDePago.IdFactura = FI_Factura.IdFactura 
						INNER JOIN  
                            dbo.PV_TipoMoneda WITH (NOLOCK)  
                                ON FI_ComplementoDePago.MonedaP = PV_TipoMoneda.TipoMonedaCorto 
						INNER JOIN
							dbo.FI_Transfer WITH (NOLOCK)  
								ON	FI_TransferFactura.IdTransfer = FI_Transfer.IdTransferencia
								AND FI_Transfer.IdContrato = @Contrato
                        LEFT JOIN  
                            dbo.CO_TipoCambioDiario WITH (NOLOCK)  
								ON CO_TipoCambioDiario.IdMoneda = PV_TipoMoneda.IdMoneda  
                                   AND CO_TipoCambioDiario.IdMoneda = FCPDR.IdMoneda  
                                   AND DAY(CO_TipoCambioDiario.Fecha) = DAY(FI_Transfer.FechaPago)  
                                   AND MONTH(CO_TipoCambioDiario.Fecha) = MONTH(FI_Transfer.FechaPago)  
                                   AND YEAR(CO_TipoCambioDiario.Fecha) = YEAR(FI_Transfer.FechaPago)  
                    WHERE  
                        #Facturas.MetodoPago = 'PPD'  
                        AND FI_TransferFactura.CvTipoDocFacturacion = @TipoComplementoPago  
                        AND CO_TipoCambioDiario.IdMoneda = FCPDR.IdMoneda  
                    GROUP BY  
                        FI_Factura.IdFactura,  
                        FI_Factura.UUID,  
                        FI_ComplementoDePago.FormaDePagoP,  
                        ISNULL(CO_TipoCambioDiario.TipoCambio, 0),
                        FI_ComplementoDePago.MonedaP,  
                        FI_Factura.TipoComprobante,  
                        CAST(
						 CASE    
                            WHEN ISNULL(CO_TipoCambioDiario.TipoCambio, 0) = 0  
                                THEN 0
								ELSE #Facturas.MontoRegistro / CO_TipoCambioDiario.TipoCambio 
							END AS DECIMAL(15, 2)),  
                        #Facturas.IdRegistro  
                UNION  
                    SELECT  
                        FI_Factura.IdFactura                                                                          AS IdFacturaCP,  
                        FI_Factura.UUID                                                                               AS UUIDCP,  
                        FI_ComplementoDePago.FormaDePagoP                                                             AS FormaPagoCP,  
                        SUM(FI_CPDocRelacionado.ImpPagado)                                                            AS MontoCP,  
                        1                                                                                             AS TipoCambioCP,  
                        FI_ComplementoDePago.MonedaP                                                                  AS MonedaCP,  
                        CAST((SUM(FI_CPDocRelacionado.ImpPagado * ISNULL(CO_TipoCambioDiario.TipoCambio, 0))) AS DECIMAL(15, 2)) AS MontoPesos,  
                        CAST((SUM(   CASE       
										WHEN PV_TipoMoneda.IdMoneda = @DOLAR
                                             THEN FI_CPDocRelacionado.ImpPagado
                                         WHEN ISNULL(CO_TipoCambioDiario.TipoCambio, 0) = 0  
                                            THEN 0  
                                         WHEN PV_TipoMoneda.IdMoneda = @PESO  
                                             THEN FI_CPDocRelacionado.ImpPagado / CO_TipoCambioDiario.TipoCambio 
										WHEN PV_TipoMoneda.IdMoneda NOT IN (@PESO, @DOLAR)
											THEN FI_CPDocRelacionado.ImpPagado / CO_TipoCambioDiario.TipoCambio 
                                     END  
                                 )  
                             ) AS DECIMAL(15, 2))                                                                     AS MontoDolares,  
                        FI_Factura.TipoComprobante,  
                        CAST(#Facturas.MontoRegistro AS DECIMAL(15, 2))                                               AS MontoRegistro,  
                        #Facturas.IdRegistro  
                    FROM #Facturas
						INNER JOIN dbo.FI_Factura FCPDR WITH (NOLOCK)  
                                ON #Facturas.IdFactura = FCPDR.IdFactura
									AND #Facturas.MetodoPago = 'PPD'
						INNER JOIN  
                            dbo.FI_CPDocRelacionado WITH (NOLOCK)  
                                ON FCPDR.UUID = FI_CPDocRelacionado.IdDocumento 
						INNER JOIN  
                            dbo.FI_ComplementoDePago WITH (NOLOCK)  
                                ON FI_CPDocRelacionado.IdComplementoDePago = FI_ComplementoDePago.IdComplementoDePago
						INNER JOIN  
                            dbo.FI_TransferFactura WITH (NOLOCK)  
                                ON FI_ComplementoDePago.IdFactura = FI_TransferFactura.IdFactura  
                                   AND FI_TransferFactura.CvTipoDocFacturacion = @TipoComplementoPago  
						INNER JOIN  
                            dbo.FI_Factura WITH (NOLOCK)  
                                ON FI_ComplementoDePago.IdFactura = FI_Factura.IdFactura 
						INNER JOIN  
                            dbo.PV_TipoMoneda WITH (NOLOCK)  
                                ON FI_ComplementoDePago.MonedaP = PV_TipoMoneda.TipoMonedaCorto 
						INNER JOIN
							dbo.FI_Transfer WITH (NOLOCK)  
								ON	FI_TransferFactura.IdTransfer = FI_Transfer.IdTransferencia
								AND FI_Transfer.IdContrato = @Contrato
                        LEFT JOIN  
                            dbo.CO_TipoCambioDiario WITH (NOLOCK)  
								ON CO_TipoCambioDiario.IdMoneda <> PV_TipoMoneda.IdMoneda  
                                   AND CO_TipoCambioDiario.IdMoneda <> FCPDR.IdMoneda  
                                   AND DAY(CO_TipoCambioDiario.Fecha) = DAY(FI_Transfer.FechaPago)  
                                   AND MONTH(CO_TipoCambioDiario.Fecha) = MONTH(FI_Transfer.FechaPago)  
                                   AND YEAR(CO_TipoCambioDiario.Fecha) = YEAR(FI_Transfer.FechaPago)     
                    WHERE  
                        #Facturas.MetodoPago = 'PPD'  
                        AND FI_TransferFactura.CvTipoDocFacturacion = @TipoComplementoPago  
                        AND FI_Transfer.IdMoneda <> PV_TipoMoneda.IdMoneda  
                        AND PV_TipoMoneda.IdMoneda = FCPDR.IdMoneda  
                    GROUP BY  
                        FI_Factura.IdFactura,  
                        FI_Factura.UUID,  
                        FI_ComplementoDePago.FormaDePagoP,  
                        FI_ComplementoDePago.MonedaP,  
                        FI_Factura.TipoComprobante,  
                        CAST(#Facturas.MontoRegistro AS DECIMAL(15, 2)),  
                        #Facturas.IdRegistro  
                UNION  
  
                    --Se agrego para los casos donde el complemento es igual a la moneda de la transferencia (USD = USD)     
                    --y la factura ppd es igual a la moneada del documento relacionado (MXN = MXN)     
                    SELECT  
                        FI_Factura.IdFactura                            AS IdFacturaCP,  
                        FI_Factura.UUID                                 AS UUIDCP,  
                        FI_ComplementoDePago.FormaDePagoP               AS FormaPagoCP,  
                        SUM(FI_CPDocRelacionado.ImpPagado)              AS MontoCP,  
                        1,  
                        FI_ComplementoDePago.MonedaP                    AS MonedaCP,  
                        CAST((SUM(   CASE  
                                         WHEN PV_TipoMoneda.IdMoneda = @DOLAR  
                                              AND FCPDR.IdMoneda = @PESO  
                                             THEN FI_CPDocRelacionado.ImpPagado * 1  
                                     END  
                                 )  
                             ) AS DECIMAL(15, 2))                       AS MontoPesos,  
                        CAST((SUM(   CASE       
                                         WHEN FCPDR.IdMoneda = @DOLAR
                                             THEN FI_CPDocRelacionado.ImpPagado
                                         WHEN ISNULL(CO_TipoCambioDiario.TipoCambio, 0) = 0  
                                            THEN 0  
                                         WHEN FCPDR.IdMoneda = @PESO  
                                             THEN FI_CPDocRelacionado.ImpPagado / CO_TipoCambioDiario.TipoCambio 
										WHEN FCPDR.IdMoneda NOT IN (@PESO, @DOLAR)
                                             THEN FI_CPDocRelacionado.ImpPagado / CO_TipoCambioDiario.TipoCambio  
                                     END  
                                 )  
                             ) AS DECIMAL(15, 2))                       AS MontoDolares,  
                        FI_Factura.TipoComprobante,  
                        CAST(#Facturas.MontoRegistro AS DECIMAL(15, 2)) AS MontoRegistro,  
                        #Facturas.IdRegistro  
                    FROM  #Facturas 
						INNER JOIN dbo.FI_Factura FCPDR WITH (NOLOCK) 
							ON #Facturas.IdFactura = FCPDR.IdFactura
								AND #Facturas.MetodoPago = 'PPD'
						INNER JOIN  
                            dbo.FI_CPDocRelacionado WITH (NOLOCK)  
                                ON FCPDR.UUID = FI_CPDocRelacionado.IdDocumento 
						INNER JOIN  
                            dbo.FI_ComplementoDePago WITH (NOLOCK)  
                                ON FI_CPDocRelacionado.IdComplementoDePago = FI_ComplementoDePago.IdComplementoDePago
						INNER JOIN  
                            dbo.FI_TransferFactura WITH (NOLOCK)  
                                ON FI_ComplementoDePago.IdFactura = FI_TransferFactura.IdFactura  
                                   AND FI_TransferFactura.CvTipoDocFacturacion = @TipoComplementoPago  
						INNER JOIN  
                            dbo.FI_Factura WITH (NOLOCK)  
                                ON FI_ComplementoDePago.IdFactura = FI_Factura.IdFactura 
						INNER JOIN  
                            dbo.PV_TipoMoneda WITH (NOLOCK)  
                                ON FI_ComplementoDePago.MonedaP = PV_TipoMoneda.TipoMonedaCorto 
						INNER JOIN
							dbo.FI_Transfer WITH (NOLOCK)  
								ON	FI_TransferFactura.IdTransfer = FI_Transfer.IdTransferencia
								AND FI_Transfer.IdContrato = @Contrato
                        LEFT JOIN  
                            dbo.CO_TipoCambioDiario WITH (NOLOCK)  
								ON CO_TipoCambioDiario.IdMoneda <> PV_TipoMoneda.IdMoneda  
                                   AND CO_TipoCambioDiario.IdMoneda = FCPDR.IdMoneda  
                                   AND DAY(CO_TipoCambioDiario.Fecha) = DAY(FI_Transfer.FechaPago)  
                                   AND MONTH(CO_TipoCambioDiario.Fecha) = MONTH(FI_Transfer.FechaPago)  
                                   AND YEAR(CO_TipoCambioDiario.Fecha) = YEAR(FI_Transfer.FechaPago)  
                    WHERE  
                        #Facturas.MetodoPago = 'PPD'  
                        AND FI_TransferFactura.CvTipoDocFacturacion = @TipoComplementoPago  
                        AND FI_Transfer.IdMoneda = PV_TipoMoneda.IdMoneda  
                        AND PV_TipoMoneda.IdMoneda <> FCPDR.IdMoneda  
                    GROUP BY  
                        FI_Factura.IdFactura,  
                        FI_Factura.UUID,  
                        FI_ComplementoDePago.FormaDePagoP,  
                        FI_ComplementoDePago.MonedaP,  
                        FI_Factura.TipoComprobante,  
                        CAST(#Facturas.MontoRegistro AS DECIMAL(15, 2)),  
                        #Facturas.IdRegistro  
  
        /**/  
        INSERT INTO #SumaDePagosDolaresBase  
            (  
                UUID,  
                Idfactura,  
                TipoComprobante,  
                MontoDolares,  
                MetodoPago,  
                TipoCambio,  
                Fecha,  
                IdMoneda,  
                MonedaTran,  
                IdTransferencia  
            )  
                    SELECT DISTINCT  
                        #Facturas.UUID,  
                        #Facturas.Idfactura,  
                        #Facturas.TipoComprobante,  
                         CASE      
                            WHEN ISNULL(CO_TipoCambioDiario.TipoCambio, 0) = 0  
                                THEN 0  
                            WHEN ISNULL(FI_TransferFactura.MontoPagado, 0) <> 0  
                                THEN CAST(ROUND(  
                                                   (ISNULL(FI_TransferFactura.MontoPagado, 0)  
                                                    / CO_TipoCambioDiario.TipoCambio  
                                                   ), 2  
                                               ) AS DECIMAL(15, 2))  
                            ELSE  
                                0  
                        END                            AS MontoDolares,  
                        #Facturas.MetodoPago,  
                        ISNULL(CO_TipoCambioDiario.TipoCambio, 0) AS TipoCambio,  
                        CO_TipoCambioDiario.Fecha,  
                        #Facturas.IdMoneda,  
                        FI_Transfer.IdMoneda           AS MonedaTran,  
                        FI_Transfer.IdTransferencia  
                    FROM  
                        dbo.FI_Transfer WITH (NOLOCK)  
                        JOIN  
                            dbo.FI_TransferFactura WITH (NOLOCK)  
                                ON FI_Transfer.IdTransferencia = FI_TransferFactura.IdTransfer  
                                   AND FI_Transfer.IdContrato = @Contrato  
                        JOIN  
                            #Facturas  
                                ON FI_TransferFactura.IdFactura = #Facturas.Idfactura  
                                   AND #Facturas.MetodoPago = 'PUE'  
                        LEFT JOIN  
                            dbo.CO_TipoCambioDiario WITH (NOLOCK)  
                                ON CO_TipoCambioDiario.IdMoneda = #Facturas.IdMoneda  
                                   AND CO_TipoCambioDiario.IdMoneda = FI_Transfer.IdMoneda  
                                   AND DAY(CO_TipoCambioDiario.Fecha) = DAY(FI_Transfer.FechaPago)  
                                   AND MONTH(CO_TipoCambioDiario.Fecha) = MONTH(FI_Transfer.FechaPago)  
                                   AND YEAR(CO_TipoCambioDiario.Fecha) = YEAR(FI_Transfer.FechaPago)  
                    WHERE  
                        #Facturas.MetodoPago = 'PUE'  
                        AND CO_TipoCambioDiario.IdMoneda = #Facturas.IdMoneda;  
  
        INSERT INTO #SumaDePagosDolaresBase  
            (  
                UUID,  
                Idfactura,  
                TipoComprobante,  
                MontoDolares,  
                MetodoPago,  
                TipoCambio,  
                Fecha,  
                IdMoneda,  
                MonedaTran,  
                IdTransferencia  
            )  
                    --     
                    SELECT DISTINCT  
                        #Facturas.UUID,  
                        #Facturas.Idfactura,  
                        #Facturas.TipoComprobante,  
                        CASE    
                            WHEN FI_Transfer.IdMoneda = @DOLAR  
                                 AND #Facturas.IdMoneda = @PESO  
                                THEN FI_TransferFactura.MontoPagado    
							WHEN ISNULL(CO_TipoCambioDiario.TipoCambio, 0) = 0  
								THEN 0  
                            WHEN FI_Transfer.IdMoneda = @PESO  
                                 AND #Facturas.IdMoneda = @DOLAR  
                                THEN CAST(ROUND(  
                                                   (ISNULL(FI_TransferFactura.MontoPagado, 0)  
                                                    / CO_TipoCambioDiario.TipoCambio  
                                                   ), 2  
                                               ) AS DECIMAL(15, 2))  
                        END                  AS MontoDolares,  
                        #Facturas.MetodoPago,  
                        CASE  
                            WHEN FI_Transfer.IdMoneda = @PESO  
                                 AND #Facturas.IdMoneda = @DOLAR  
                                THEN 1  
                            WHEN FI_Transfer.IdMoneda = @DOLAR  
                                 AND #Facturas.IdMoneda = @PESO  
                                THEN ISNULL(CO_TipoCambioDiario.TipoCambio, 0)  
                        END                  AS TipoCambio,  
                        CO_TipoCambioDiario.Fecha,  
                        #Facturas.IdMoneda,  
                        FI_Transfer.IdMoneda AS MonedaTran,  
                        FI_Transfer.IdTransferencia  
                    FROM  #Facturas
						INNER JOIN dbo.FI_TransferFactura WITH (NOLOCK)  
							ON FI_TransferFactura.IdFactura = #Facturas.Idfactura  
                                   AND #Facturas.MetodoPago = 'PUE' 
						INNER JOIN dbo.FI_Transfer WITH (NOLOCK)  
							ON FI_TransferFactura.IdTransfer = FI_Transfer.IdTransferencia
								AND FI_Transfer.IdContrato = @Contrato  
                        LEFT JOIN  
                            dbo.CO_TipoCambioDiario WITH (NOLOCK)  
                                ON CO_TipoCambioDiario.IdMoneda = FI_Transfer.IdMoneda  
                                   AND CO_TipoCambioDiario.IdMoneda <> #Facturas.IdMoneda  
                                   AND DAY(CO_TipoCambioDiario.Fecha) = DAY(FI_Transfer.FechaPago)  
                                   AND MONTH(CO_TipoCambioDiario.Fecha) = MONTH(FI_Transfer.FechaPago)  
                                   AND YEAR(CO_TipoCambioDiario.Fecha) = YEAR(FI_Transfer.FechaPago)  
                    WHERE  
                        #Facturas.MetodoPago = 'PUE'  
                        AND CO_TipoCambioDiario.IdMoneda <> #Facturas.IdMoneda;  
  
        INSERT INTO #SumaDePagosDolares  
            (  
                UUID,  
                Idfactura,  
                TipoComprobante,  
                MontoDolares,  
                MetodoPago,  
                TipoCambio,  
                Fecha,  
                IdMoneda  
            )  
                    SELECT  
                        UUID,  
                        Idfactura,  
                        TipoComprobante,  
                        SUM(MontoDolares) AS MontoDolares,  
                        MetodoPago,  
                        MAX(TipoCambio)   AS TipoCambio,  
                        MAX(Fecha)        AS Fecha,  
                        IdMoneda  
                    FROM  
                        #SumaDePagosDolaresBase  
                    GROUP BY  
                        UUID,  
                        Idfactura,  
                        TipoComprobante,  
                        MetodoPago,  
                        IdMoneda;  
  
        --     
        INSERT INTO #MontosTotalTransferenciaPUE  
            (  
                IdRegistro,  
                UUID,  
                Idfactura,  
                MontoRegistro,  
                TipoComprobante,  
                RC2122,  
                MetodoPago,  
                TCD,  
                FechaTCD,  
                IdMoneda  
            )  
                    SELECT DISTINCT  
                        #Facturas.IdRegistro,  
                        #Facturas.UUID,  
                        #Facturas.Idfactura,  
                        #Facturas.MontoRegistro,  
                        #Facturas.TipoComprobante,  
                        #SumaDePagosDolares.MontoDolares,  
                        #Facturas.MetodoPago,  
                        #SumaDePagosDolares.TipoCambio,  
                        #SumaDePagosDolares.Fecha,  
                        #Facturas.IdMoneda  
                    FROM  
                        #Facturas  
                        JOIN  
                            #SumaDePagosDolares  
                                ON #Facturas.Idfactura = #SumaDePagosDolares.Idfactura  
                    WHERE  
                        #Facturas.MetodoPago = 'PUE';  
  
        /*PEDIMENTO COMPROBANTE*/  
        --     
        INSERT INTO #MontosConvertidosPedimentosCom  
            (  
                IdRegistro,  
                IdPedimentoComprobante,  
                MontoRegistro,  
                RC2122,  
                TCD  
            )  
                    SELECT  
                        CO_Registro.IdRegistro,  
                        FI_PedimentoComprobante.IdPedimentoComprobante,  
                        CO_Registro.MontoRegistro,  
                        SUM(   CASE      
								  WHEN ISNULL(CO_TipoCambioDiario.TipoCambio, 0) = 0  
									   THEN 0  
                                   WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0  
                                       THEN CAST(ROUND(  
                                                          (ISNULL(CO_Registro.MontoRegistro, 0)  
                                                           / CO_TipoCambioDiario.TipoCambio  
                                                          ), 2  
                                                      ) AS DECIMAL(15, 2))  
                                   ELSE  
                                       0  
                               END  
                           )                   AS [RC21_22],  
                        ISNULL(CO_TipoCambioDiario.TipoCambio, 0)  
                    FROM  
                        dbo.CO_Registro WITH (NOLOCK)  
                        JOIN  
                            dbo.FI_PedimentoComprobante WITH (NOLOCK)  
                                ON FI_PedimentoComprobante.IdPedimentoComprobante = CO_Registro.IdPedimentoComprobante  
                                   AND CO_Registro.IdEstado = @Aprobado  
                                   AND CO_Registro.CvTipoDocFacturacion IN (  
                                                                                @TipoPedimentoImportacion, @TipoComprobanteExtranjero 
                                                                           )  
                                   AND FI_PedimentoComprobante.IdContrato = @Contrato  
                        JOIN  
                            dbo.CO_Contrato WITH (NOLOCK)  
                                ON FI_PedimentoComprobante.IdContrato = CO_Contrato.IdContrato  
                                   AND CO_Contrato.IdContrato = @Contrato  
                        JOIN  
                            dbo.CO_LineaPresupuestoMes WITH (NOLOCK)  
                                ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes  
                        JOIN  
                            dbo.CO_Servicio WITH (NOLOCK)  
                                ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio  
                        JOIN  
                            dbo.FI_TransferFactura WITH (NOLOCK)  
                                ON FI_PedimentoComprobante.IdPedimentoComprobante = FI_TransferFactura.IdPedimentoComprobante  
                        JOIN  
                            dbo.FI_Transfer WITH (NOLOCK)  
                                ON FI_TransferFactura.IdTransfer = FI_Transfer.IdTransferencia  
                        LEFT JOIN  
                            dbo.CO_TipoCambioDiario WITH (NOLOCK)  
                                ON CO_TipoCambioDiario.IdMoneda = FI_PedimentoComprobante.IdMoneda  
                                   AND DAY(CO_TipoCambioDiario.Fecha) = DAY(FI_Transfer.FechaPago)  
                                   AND MONTH(CO_TipoCambioDiario.Fecha) = MONTH(FI_Transfer.FechaPago)  
                                   AND YEAR(CO_TipoCambioDiario.Fecha) = YEAR(FI_Transfer.FechaPago)  
                    WHERE  
                        CO_Contrato.IdContrato = @Contrato  
                        AND CO_Registro.IdEstado = @Aprobado  
                        AND CO_Registro.CvTipoDocFacturacion IN (  
                                                                    @TipoPedimentoImportacion, @TipoComprobanteExtranjero   
                                                                )  
                        AND ISNULL(CONVERT(INT, FI_PedimentoComprobante.ProcesadoSIPAC), 0) = 0  
                        AND CO_Servicio.NombreServicio NOT LIKE '%No elegibles%'  
                        AND CO_LineaPresupuestoMes.IdPresupuesto = CASE  
                                                                       WHEN @IdPresupuesto = 0  
                                                                           THEN CO_LineaPresupuestoMes.IdPresupuesto  
                                                                       ELSE  
                                                                           @IdPresupuesto  
                                                                   END  
                    GROUP BY  
						CO_Registro.IdRegistro,  
                        FI_PedimentoComprobante.IdPedimentoComprobante,  
                        CO_Registro.MontoRegistro,  
                        ISNULL(CO_TipoCambioDiario.TipoCambio, 0);  
  
        /*Determinar si tiene gastos o no en el mes seleccionado. Si no tiene devuelve el registro para reportar en 0*/  
        --     
        SELECT  
            @GastosConFacturaPPD = COUNT(IdRegistro)  
        FROM  
            #MontosTotalTransferenciaPPD;  
  
        --     
        SELECT  
            @GastosConFacturaPUE = COUNT(IdRegistro)  
        FROM  
            #MontosTotalTransferenciaPUE;  
  
        --     
        SELECT  
            @GastosConPedCom = COUNT(IdRegistro)  
        FROM  
            #MontosConvertidosPedimentosCom;  
  
        --     
        IF (  
               @GastosConFacturaPPD = 0  
               AND @GastosConFacturaPUE = 0  
               AND @GastosConPedCom = 0  
           )  
            BEGIN  
                INSERT INTO #ResultadosGastos  
                    (  
                        RF_00,  
                        RI_00,  
                        RF01_01,  
                        RC21_00,  
                        RC21_01,  
                        RC21_02,  
                        RC21_03,  
                        RC21_04,  
                        RC21_05,  
                        RC21_06,  
                        RC21_07,  
                        RC21_08,  
                        RC21_09,  
                        RC21_10,  
                        RC21_11,  
                        RC21_12,  
                        RC21_13,  
                        RC21_14,  
                        RC21_15,  
                        RC21_16,  
                        RC21_17,  
                        RC21_18,  
                        RC21_19,  
                        RC21_20,  
                        RC21_21,  
                        RC21_22,  
                        RC21_23,  
                        RC21_24,  
                        RC21_25,  
                        RC21_26,  
                        RC21_27,  
                        RC21_28  
                    )  
                            SELECT DISTINCT  
                                CASE  
                                    WHEN ISNULL(CO_Contrato.IDSIPAC, '') <> ''  
                                        THEN LTRIM(RTRIM(CO_Contrato.IDSIPAC))  
                                    ELSE  
                                        LTRIM(RTRIM(CO_Contratista.IDSIPAC))  
                                END                                         AS [RF_00],  
                                LTRIM(RTRIM(CO_Contrato.IDRegFiducidiario)) AS [RI_00],  
                                LTRIM(RTRIM(CO_Contrato.NumeroContrato))    AS [RF01_01],  
                                CASE  
                                    WHEN len(CO_Presupuesto.IdPresupuestoCNH) > 10  
                                        THEN SUBSTRING(CO_Presupuesto.IdPresupuestoCNH, 22, 10)  
                                    ELSE  
                                        CO_Presupuesto.IdPresupuestoCNH  
                                END                                         AS [RC21_00],  
                                ''											AS [RC21_01],  
                                ''											AS [RC21_02],  
                                1                                           AS [RC21_03],  
                                NULL                                        AS [RC21_04],  
                                NULL                                        AS [RC21_05],  
                                NULL                                        AS [RC21_06],  
                                NULL                                        AS [RC21_07],  
                                NULL                                        AS [RC21_08],  
                                NULL                                        AS [RC21_09],  
                                NULL                                        AS [RC21_10],  
                                NULL                                        AS [RC21_11],  
                                NULL                                        AS [RC21_12],  
                                NULL                                        AS [RC21_13],  
                                NULL                                        AS [RC21_14],  
                                NULL                                        AS [RC21_15],  
                                NULL                                        AS [RC21_16],  
                                NULL                                        AS [RC21_17],  
                                NULL                                        AS [RC21_18],  
                                NULL                                        AS [RC21_19],  
                                NULL                                        AS [RC21_20],  
                                NULL                                        AS [RC21_21],  
                                0                                           AS [RC21_22],  
                                0                                           AS [RC21_23],  
                                NULL                                        AS [RC21_24],  
                                NULL                                        AS [RC21_25],  
                                NULL                                        AS [RC21_26],  
                                0                                           AS [RC21_27],  
                                NULL                                        AS [RC21_28]  
                            FROM  
                                dbo.CO_Contrato WITH (NOLOCK)  
                                JOIN  
                                    dbo.CO_Contratista WITH (NOLOCK)  
                                        ON CO_Contrato.IdContratista = CO_Contratista.IdContratista  
                                           AND CO_Contrato.IdContrato = @Contrato  
                                JOIN  
                                    dbo.CO_AnioContractual WITH (NOLOCK)  
                                        ON CO_Contrato.IdContrato = CO_AnioContractual.IdContrato  
                                JOIN  
                                    dbo.CO_Presupuesto WITH (NOLOCK)  
                                        ON CO_AnioContractual.IdAnioContractual = CO_Presupuesto.IdAnioContractual  
                            WHERE  
                                CO_Contrato.IdContrato = @Contrato  
                                AND SUBSTRING(ISNULL(CO_Presupuesto.IdPresupuestoCNH, ''), 22, 10) <> ''  
                                AND CO_Presupuesto.IdPresupuesto = CASE  
                                                                       WHEN @IdPresupuesto = 0  
                                                                           THEN CO_Presupuesto.IdPresupuesto  
                                                                       ELSE  
                                                                           @IdPresupuesto  
                                                                   END;  
            END;  
        ELSE  
            BEGIN  
                INSERT INTO #ResultadosGastos  
                    (  
                        RF_00,  
                        RI_00,  
                        RF01_01,  
                        RC21_00,  
                        RC21_01,  
                        RC21_02,  
                        RC21_03,  
                        RC21_04,  
                        RC21_05,  
                        RC21_06,  
                        RC21_07,  
                        RC21_08,  
                        RC21_09,  
                        RC21_10,  
                        RC21_11,  
                        RC21_12,  
                        RC21_13,  
						RC21_14,  
                        RC21_15,  
                        RC21_16,  
                        RC21_17,  
                        RC21_18,  
                        RC21_19,  
                        RC21_20,  
                        RC21_21,  
                        RC21_22,  
                        RC21_23,  
                        RC21_24,  
                        RC21_25,  
                        RC21_26,  
                        RC21_27,  
                        RC21_28  
                    )  
                            SELECT  
                                CASE  
                                    WHEN ISNULL(C.IDSIPAC, '') <> ''  
                                        THEN LTRIM(RTRIM(C.IDSIPAC))  
                                    ELSE  
                                        LTRIM(RTRIM(CON.IDSIPAC))  
                                END                                                    AS [RF_00],  
                                LTRIM(RTRIM(C.IDRegFiducidiario))                      AS [RI_00],  
                                C.NumeroContrato                                       AS [RF01_01],  
                                CASE  
                                    WHEN len(P.IdPresupuestoCNH) > 10  
                                        THEN SUBSTRING(P.IdPresupuestoCNH, 22, 10)  
                                    ELSE  
                                        P.IdPresupuestoCNH  
                                END                                                    AS [RC21_00],  
                                MONTH(CO_Registro.MesPresentacion)                     AS [RC21_01],  
                                YEAR(CO_Registro.MesPresentacion)                      AS [RC21_02],  
                                NULL                                                   AS [RC21_03],  
                                ISNULL(SUBSTRING(F.IdDocFacturacionSIPAC, 1, 2), 'CF') AS [RC21_04], 
								-- SE AGREGA ISNULL CF, YA QUE SE ENCONTRO EN EL ISSUE 2394 NOTAS DE CREDITO EN PPD Y SOPORTE LAS AJUSTA A PUE PARA QUE SE PUEDAN PRESENTAR, ES CONSULTA 
								-- SOLO DE FACTURA Y SE CONFIRMA QUE ES CORRECTO QUE NO SE VISUALICE EN LA HOJA 22 NI EN EL ZIP DE ARCHIVOS   AS [RC21_04],    
                                CASE  
                                    WHEN CO_Registro.CvTipoDocFacturacion = @TipoFactura  
                                        THEN ISNULL(F.UUID, 'NÚMERO NO REGISTRADO')  
                                    ELSE  
                                        'NA'  
                                END                                                    AS [RC21_05],  
                                'NA'                                                   AS [RC21_06],  
                                'NA'                                                   AS [RC21_07],  
                                TTF.TipoComprobante                                    AS [RC21_08],  
                                TTF.MetodoPago                                         AS [RC21_09],  
                                LTRIM(RTRIM(APCNH.id_Actividad))                       AS [RC21_10],  
                                LTRIM(RTRIM(SP.[id_Sub-actividad]))                    AS [RC21_11],  
                                LTRIM(RTRIM(TP.id_Tarea))                              AS [RC21_12],  
                                CASE  
                                    WHEN CO_Registro.CostosAtribuiblesAdministracion = 1  
                                        THEN 1  
                                    ELSE  
                                        0  
                                END                                                    AS [RC21_13],  
                                CASE  
                                    WHEN CO_Registro.CostosAtribuiblesAdministracion = 1  
                                        THEN 'NA'  
                                    ELSE  
                                        LTRIM(RTRIM(ISNULL(CPO.NombreCampo, '-')))  
                       END                                                    AS [RC21_14],  
                                CASE  
                                    WHEN CO_Registro.CostosAtribuiblesAdministracion = 1  
                                        THEN 'NA'  
                                    ELSE  
                                        LTRIM(RTRIM(ISNULL(Y.NombreYacimiento, '-')))  
                                END                                                    AS [RC21_15],  
                                CASE  
                                    WHEN CO_Registro.CostosAtribuiblesAdministracion = 1  
                                        THEN 'NA'  
                                    ELSE  
                                        LTRIM(RTRIM(I.NombreInstalacion))  
                                END                                                    AS [RC21_16],  
                                CC.Nivel3                                              AS [RC21_17],  
                                CC.Descripcion                                         AS [RC21_18],  
                                CO_Registro.Poliza                                     AS [RC21_19],  
                                SUBSTRING(CO_Registro.Comentarios, 0, 299)             AS [RC21_20],  
                                CASE  
                                    WHEN CO_Registro.CapexOpexEdicion IS NOT NULL  
                                        THEN CASE  
                                                 WHEN CO_Registro.CapexOpexEdicion = 1  
                                                     THEN 1  
                                                 ELSE  
                                                     2  
                                             END  
                                    ELSE  
                                        CASE  
                                            WHEN CC.Operacion = 1  
                                                THEN 1  
                                            ELSE  
                                                2  
                                        END  
                                END                                                    AS [RC21_21],  
                                SUM(   CASE 
                                           WHEN ISNULL(TTF.TCD, 0) = 0  
                                               THEN 0   
                                           WHEN ISNULL(TTF.MontoRegistro, 0) <> 0  
                                                AND TTF.TipoComprobante IN (  
                                                                               'I', 'N', 'P'  
                                                                           )  
                                               THEN CAST((TTF.MontoRegistro / TTF.TCD)  
                                                         * (TTF.RC2122 / (F.MontoConIva / TTF.TCD)) AS DECIMAL(15, 2))  
                                           ELSE  
                                               0  
                                       END  
                                   )                                                   AS [RC21_22],  
                                SUM(ABS(   CASE  
											   WHEN ISNULL(TTF.TCD, 0) = 0  
                                                  THEN 0  
                                               WHEN ISNULL(TTF.MontoRegistro, 0) <> 0  
                                                    AND TTF.TipoComprobante IN (  
                                                                                   'E'  
                                                                               )  
                                                   THEN CAST((TTF.MontoRegistro / TTF.TCD)  
                                                             * (TTF.RC2122 / (F.MontoConIva / TTF.TCD)) AS DECIMAL(15, 2))  
                                               ELSE  
                                                   0  
                                           END  
                                       )  
                                   )                                                   AS [RC21_23],  
								TM.TipoMonedaCorto                                     AS [RC21_24],  
                                CAST(ISNULL(TTF.TCD, 0) AS DECIMAL(15, 4))                        AS [RC21_25],  
                                CASE  
                                    WHEN ISNULL(RE.IdRelacionada, 2) <> 2  
                                        THEN 1  
                                    ELSE  
                                        2  
                                END                                                    AS [RC21_26],  
                                CASE @Plantilla  
                                    WHEN 'CGI_2022'  
                                        THEN ISNULL(CO_Registro.RegistroConAjuste, 0)  
                                    ELSE  
                                        0  
                                END                                                    AS [RC21_27],  
                                CASE @Plantilla  
                                    WHEN 'CGI_2022'  
                                        THEN ISNULL(CO_Registro.AsociadoIncrementoPMT, 0)  
                                    ELSE  
                                        0  
                                END                                                    AS [RC21_28]  
                            FROM  
                                dbo.CO_Registro WITH (NOLOCK)  
                                JOIN  
                                    dbo.FI_Factura               F WITH (NOLOCK)  
                                        ON CO_Registro.IdFactura = F.IdFactura  
                                           AND CO_Registro.IdEstado = @Aprobado  
                                JOIN  
                                    #MontosTotalTransferenciaPUE TTF  
                                        ON TTF.Idfactura = CO_Registro.IdFactura  
                                           AND TTF.IdRegistro = CO_Registro.IdRegistro  
                                           AND TTF.MetodoPago = 'PUE'  
                                JOIN  
                                    dbo.CO_LineaPresupuestoMes   LPM WITH (NOLOCK)  
                                        ON CO_Registro.IdPrograma = LPM.IdLineaPresupuestoMes  
                                JOIN  
                                    dbo.CO_Presupuesto           P WITH (NOLOCK)  
                                        ON LPM.IdPresupuesto = P.IdPresupuesto  
                                JOIN  
                                    dbo.CO_AnioContractual       AC WITH (NOLOCK)  
                                        ON P.IdAnioContractual = AC.IdAnioContractual  
                                           AND AC.IdContrato = @Contrato  
                                JOIN  
                                    dbo.CO_Contrato              C WITH (NOLOCK)  
                                        ON AC.IdContrato = C.IdContrato  
                                           AND C.IdContrato = @Contrato  
                                JOIN  
                                    dbo.CO_Contratista           CON WITH (NOLOCK)  
                                        ON C.IdContratista = CON.IdContratista  
                                JOIN  
                                    dbo.CO_ActividadPetroleraCNH APCNH WITH (NOLOCK)  
                                        ON LPM.IdActividadPetrolera = APCNH.IdActividadPetrolera  
                                JOIN  
                                    dbo.CO_SubactividadPetrolera SP WITH (NOLOCK)  
                                        ON LPM.IdSubactividadPetrolera = SP.IdSubactividadPetrolera  
                                JOIN  
                                    dbo.CO_TareaPetrolera        TP WITH (NOLOCK)  
                                        ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera  
                                JOIN  
                                    dbo.CO_Instalacion           I WITH (NOLOCK)  
                                        ON CO_Registro.IdInstalacion = I.IdInstalacion  
                                JOIN  
                                    dbo.CO_Servicio              S WITH (NOLOCK)  
                                        ON LPM.IdServicio = S.IdServicio  
                                           AND C.IdContrato = S.IdContrato  
                                LEFT JOIN  
                                    dbo.PD_Campo                 CPO WITH (NOLOCK)  
                                        ON I.IdCampo = CPO.IdCampo  
                                LEFT JOIN  
                                    dbo.CO_Yacimiento            Y WITH (NOLOCK)  
                                        ON CPO.IdYacimiento = Y.IdYacimiento  
                                LEFT JOIN  
                                    dbo.CO_CatalogoCuentaSH      CC WITH (NOLOCK)  
                                        ON CC.IdCatalogoCuentasSH = CO_Registro.IdCatalogoCuentasSH  
                                LEFT JOIN  
                                    dbo.PV_TipoMoneda            TM WITH (NOLOCK)  
                                        ON F.IdMoneda = TM.IdMoneda  
                                LEFT JOIN  
                                    dbo.CO_RelacionEmpresas      RE WITH (NOLOCK)  
                                        ON RE.IdContratista = CON.IdContratista  
                                           AND F.IdSubcontratista = RE.IdRelacionada  
                            WHERE  
                                C.IdContrato = @Contrato  
                                AND CO_Registro.IdEstado = @Aprobado  
                                AND CO_Registro.CvTipoDocFacturacion = @TipoFactura  
                                AND ISNULL(CONVERT(INT, F.ProcesadoSIPAC), 0) = 0  
                                AND S.NombreServicio NOT LIKE '%No elegibles%'  
                                AND TTF.MetodoPago = 'PUE'  
                                AND P.IdPresupuesto = CASE  
                                                          WHEN @IdPresupuesto = 0  
                                                              THEN LPM.IdPresupuesto  
                                                          ELSE  
                                                              @IdPresupuesto  
                                                      END  
                            GROUP BY  
                                CASE  
                                    WHEN ISNULL(C.IDSIPAC, '') <> ''  
                                        THEN LTRIM(RTRIM(C.IDSIPAC))  
                                    ELSE  
                                        LTRIM(RTRIM(CON.IDSIPAC))  
                                END,  
                                LTRIM(RTRIM(C.IDRegFiducidiario)),  
                                C.NumeroContrato,  
                                CASE  
                                    WHEN len(P.IdPresupuestoCNH) > 10  
                                        THEN SUBSTRING(P.IdPresupuestoCNH, 22, 10)  
                                    ELSE  
                                        P.IdPresupuestoCNH  
                                END,  
                                MONTH(CO_Registro.MesPresentacion),  
                                YEAR(CO_Registro.MesPresentacion),  
                                ISNULL(SUBSTRING(F.IdDocFacturacionSIPAC, 1, 2), 'CF'),  
                                CASE  
                                    WHEN CO_Registro.CvTipoDocFacturacion = @TipoFactura  
                                        THEN ISNULL(F.UUID, 'NÚMERO NO REGISTRADO')  
                                    ELSE  
                                        'NA'  
                                END,  
								LTRIM(RTRIM(APCNH.id_Actividad)),  
                                LTRIM(RTRIM(SP.[id_Sub-actividad])),  
                                LTRIM(RTRIM(TP.id_Tarea)),  
                                CASE  
                                    WHEN CO_Registro.CostosAtribuiblesAdministracion = 1  
                                        THEN 1  
                                    ELSE  
                                        0  
                                END,  
                                CASE  
                                    WHEN CO_Registro.CostosAtribuiblesAdministracion = 1  
                                        THEN 'NA'  
                                    ELSE  
                                        LTRIM(RTRIM(ISNULL(CPO.NombreCampo, '-')))  
                                END,  
                                CASE  
                                    WHEN CO_Registro.CostosAtribuiblesAdministracion = 1  
                                        THEN 'NA'  
                                    ELSE  
                                        LTRIM(RTRIM(ISNULL(Y.NombreYacimiento, '-')))  
                                END,  
                                CASE  
                                    WHEN CO_Registro.CostosAtribuiblesAdministracion = 1  
                                        THEN 'NA'  
                                    ELSE  
                                        LTRIM(RTRIM(I.NombreInstalacion))  
                                END,  
                                CASE  
                                    WHEN CO_Registro.CapexOpexEdicion IS NOT NULL  
                                        THEN CASE  
                                                 WHEN CO_Registro.CapexOpexEdicion = 1  
                                                     THEN 1  
                                                 ELSE  
                                                     2  
                                             END  
                                    ELSE  
                                        CASE  
                                            WHEN CC.Operacion = 1  
                                                THEN 1  
                                            ELSE  
                                                2  
                                        END  
                                END,  
                                CASE  
                                    WHEN ISNULL(RE.IdRelacionada, 2) <> 2  
                                        THEN 1  
                                    ELSE  
                                        2  
                                END,  
                                TTF.TipoComprobante,  
                                TTF.MetodoPago,  
                                CC.Nivel3,  
                                CC.Descripcion,  
                                CO_Registro.Poliza,  
                                SUBSTRING(CO_Registro.Comentarios, 0, 299),  
                                TM.TipoMonedaCorto,  
                                CAST(ISNULL(TTF.TCD, 0) AS DECIMAL(15, 4)),  
                                CASE @Plantilla  
                                    WHEN 'CGI_2022'  
                                        THEN ISNULL(CO_Registro.RegistroConAjuste, 0)  
                                    ELSE  
                                        0  
                                END,  
                                CASE @Plantilla  
                                    WHEN 'CGI_2022'  
                                        THEN ISNULL(CO_Registro.AsociadoIncrementoPMT, 0)  
                                    ELSE  
                                        0  
                                END  
                            --     
  
                            UNION  
  
                            --     
                            SELECT  
                                CASE  
                                    WHEN ISNULL(C.IDSIPAC, '') <> ''  
										THEN LTRIM(RTRIM(C.IDSIPAC))  
                                    ELSE  
                                        LTRIM(RTRIM(CON.IDSIPAC))  
                                END                                                      AS [RF_00],  
                                LTRIM(RTRIM(C.IDRegFiducidiario))                        AS [RI_00],  
                                C.NumeroContrato                                         AS [RF01_01],  
                                CASE  
                                    WHEN len(P.IdPresupuestoCNH) > 10  
                                        THEN SUBSTRING(P.IdPresupuestoCNH, 22, 10)  
                                    ELSE  
                                        P.IdPresupuestoCNH  
                                END                                                      AS [RC21_00],  
                                MONTH(CO_Registro.MesPresentacion)                       AS [RC21_01],  
                                YEAR(CO_Registro.MesPresentacion)                        AS [RC21_02],  
                                NULL                                                     AS [RC21_03],  
                                ISNULL(SUBSTRING(FCP.IdDocFacturacionSIPAC, 1, 2), 'CF') AS [RC21_04], 
								-- SE AGREGA ISNULL CF, YA QUE SE ENCONTRO EN EL ISSUE 2394 NOTAS DE CREDITO EN PPD Y SOPORTE LAS AJUSTA A PUE PARA QUE SE PUEDAN PRESENTAR, ES CONSULTA
								--SOLO DE FACTURA Y SE CONFIRMA QUE ES CORRECTO QUE NO SE VISUALICE EN LA HOJA 22 NI EN EL ZIP DE ARCHIVOS  
                                CASE  
                                    WHEN CO_Registro.CvTipoDocFacturacion = @TipoFactura  
                                        THEN ISNULL(FCP.UUID, 'NÚMERO NO REGISTRADO')  
                                    ELSE  
                                        'NA'  
                                END                                                      AS [RC21_05],  
                                'NA'                                                     AS [RC21_06],  
                                'NA'                                                     AS [RC21_07],  
                                FCP.TipoComprobante                                      AS [RC21_08],  
                                'PPD'                                                    AS [RC21_09],  
                                LTRIM(RTRIM(APCNH.id_Actividad))                         AS [RC21_10],  
                                LTRIM(RTRIM(SP.[id_Sub-actividad]))                      AS [RC21_11],  
                                LTRIM(RTRIM(TP.id_Tarea))                                AS [RC21_12],  
                                CASE  
                                    WHEN CO_Registro.CostosAtribuiblesAdministracion = 1  
                                        THEN 1  
                                    ELSE  
                                        0  
                                END                                                      AS [RC21_13],  
                                CASE  
                                    WHEN CO_Registro.CostosAtribuiblesAdministracion = 1  
                                        THEN 'NA'  
                                    ELSE  
                                        LTRIM(RTRIM(ISNULL(CPO.NombreCampo, '-')))  
                                END                                                      AS [RC21_14],  
                                CASE  
                                    WHEN CO_Registro.CostosAtribuiblesAdministracion = 1  
                                        THEN 'NA'  
                                    ELSE  
                                        LTRIM(RTRIM(ISNULL(Y.NombreYacimiento, '-')))  
                                END                                                      AS [RC21_15],  
                                CASE  
                                    WHEN CO_Registro.CostosAtribuiblesAdministracion = 1  
										THEN 'NA'  
                                    ELSE  
                                        LTRIM(RTRIM(I.NombreInstalacion))  
                                END                                                      AS [RC21_16],  
                                CC.Nivel3                                                AS [RC21_17],  
                                CC.Descripcion                                           AS [RC21_18],  
                                CO_Registro.Poliza                                       AS [RC21_19],  
                                SUBSTRING(CO_Registro.Comentarios, 0, 299)               AS [RC21_20],  
                                CASE  
                                    WHEN CO_Registro.CapexOpexEdicion IS NOT NULL  
                                        THEN CASE  
                                                 WHEN CO_Registro.CapexOpexEdicion = 1  
                                                     THEN 1  
                                                 ELSE  
                                                     2  
                                             END  
                                    ELSE  
                                        CASE  
                                            WHEN CC.Operacion = 1  
                                                THEN 1  
                                            ELSE  
                                                2  
                                        END  
                                END                                                      AS [RC21_21],  
                                SUM(   CASE   
                                           WHEN ISNULL(TTF.TipoCambioCP, 0) = 0  
                                               THEN 0  
                                           WHEN ISNULL(TTF.MontoRegistro, 0) <> 0  
                                                AND TTF.TipoComprobante IN (  
                                                                               'I', 'N', 'P'  
                                                                           )  
                                               THEN CAST(TTF.MontoRegistro  
                                                         * (TTF.MontoDolares / (F.MontoConIva / TTF.TipoCambioCP)) AS DECIMAL(15, 2))  
                                           ELSE  
                                               0  
                                       END  
                                   )                                                     AS [RC21_22],  
                                SUM(ABS(   CASE  
                                               WHEN ISNULL(TTF.MontoRegistro, 0) <> 0  
                                                    AND TTF.TipoComprobante IN (  
                                                                                   'E'  
                                                                               )  
                                                   THEN CAST(TTF.MontoDolares AS DECIMAL(15, 2))  
                                               ELSE  
                                                   0  
                                           END  
                                       )  
                                   )                                                     AS [RC21_23],  
                                TM.TipoMonedaCorto                                       AS [RC21_24],  
                                CAST(ISNULL(TTF.TipoCambioCP,0)  AS DECIMAL(15, 4))      AS [RC21_25],  
                                CASE  
                                    WHEN ISNULL(RE.IdRelacionada, 2) <> 2  
                                        THEN 1  
                                    ELSE  
                                        2  
                                END              AS [RC21_26],  
                                CASE @Plantilla  
                                    WHEN 'CGI_2022'  
                                        THEN ISNULL(CO_Registro.RegistroConAjuste, 0)  
                                    ELSE  
                                        0  
                                END                                                      AS [RC21_27],  
                                CASE @Plantilla  
                                    WHEN 'CGI_2022'  
                                        THEN ISNULL(CO_Registro.AsociadoIncrementoPMT, 0)  
                                    ELSE  
                                        0  
                                END                                                      AS [RC21_28]  
                            FROM  
                                dbo.CO_Registro WITH (NOLOCK)  
                                JOIN  
                                    dbo.FI_Factura               F WITH (NOLOCK)  
                                        ON CO_Registro.IdFactura = F.IdFactura  
                                           AND CO_Registro.IdEstado = @Aprobado  
                                           AND CO_Registro.CvTipoDocFacturacion = @TipoFactura  
                                JOIN  
                                    dbo.FI_CPDocRelacionado      CPDR WITH (NOLOCK)  
                                        ON F.UUID = CPDR.IdDocumento  
                                JOIN  
                                    dbo.FI_ComplementoDePago     CP WITH (NOLOCK)  
                                        ON CPDR.IdComplementoDePago = CP.IdComplementoDePago  
                                JOIN  
                                    #MontosTotalTransferenciaPPD TTF  
                                        ON CP.IdFactura = TTF.IdFacturaCP  
                                           AND CO_Registro.IdRegistro = TTF.IdRegistro  
                                JOIN  
                                    dbo.FI_Factura               FCP WITH (NOLOCK)  
                                        ON TTF.IdFacturaCP = FCP.IdFactura  
                                JOIN  
                                    dbo.CO_LineaPresupuestoMes   LPM WITH (NOLOCK)  
                                        ON CO_Registro.IdPrograma = LPM.IdLineaPresupuestoMes  
                                JOIN  
                                    dbo.CO_Presupuesto           P WITH (NOLOCK)  
                                        ON LPM.IdPresupuesto = P.IdPresupuesto  
                                JOIN  
                                    dbo.CO_AnioContractual       AC WITH (NOLOCK)  
                                        ON P.IdAnioContractual = AC.IdAnioContractual  
                                           AND AC.IdContrato = @Contrato  
                                JOIN  
                                    dbo.CO_Contrato              C WITH (NOLOCK)  
                                        ON AC.IdContrato = C.IdContrato  
                                           AND C.IdContrato = @Contrato  
                                JOIN  
                                    dbo.CO_Contratista           CON WITH (NOLOCK)  
                                        ON C.IdContratista = CON.IdContratista  
                                JOIN  
                                    dbo.CO_ActividadPetroleraCNH APCNH WITH (NOLOCK)  
                                        ON LPM.IdActividadPetrolera = APCNH.IdActividadPetrolera  
                                JOIN  
                                    dbo.CO_SubactividadPetrolera SP WITH (NOLOCK)  
                                        ON LPM.IdSubactividadPetrolera = SP.IdSubactividadPetrolera  
                                JOIN  
                                    dbo.CO_TareaPetrolera        TP WITH (NOLOCK)  
                                        ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera  
                                JOIN  
									dbo.CO_Instalacion           I WITH (NOLOCK)  
                                        ON CO_Registro.IdInstalacion = I.IdInstalacion  
                                JOIN  
                                    dbo.CO_Servicio              S WITH (NOLOCK)  
                                        ON LPM.IdServicio = S.IdServicio  
                                           AND C.IdContrato = S.IdContrato  
                                LEFT JOIN  
                                    dbo.PD_Campo                 CPO WITH (NOLOCK)  
                                        ON I.IdCampo = CPO.IdCampo  
                                LEFT JOIN  
                                    dbo.CO_Yacimiento            Y WITH (NOLOCK)  
                                        ON CPO.IdYacimiento = Y.IdYacimiento  
                                LEFT JOIN  
                                    dbo.CO_CatalogoCuentaSH      CC WITH (NOLOCK)  
                                        ON CC.IdCatalogoCuentasSH = CO_Registro.IdCatalogoCuentasSH  
                                LEFT JOIN  
                                    dbo.PV_TipoMoneda            TM WITH (NOLOCK)  
                                        ON F.IdMoneda = TM.IdMoneda  
                                LEFT JOIN  
                                    dbo.CO_RelacionEmpresas      RE WITH (NOLOCK)  
                                        ON RE.IdContratista = CON.IdContratista  
                                           AND F.IdSubcontratista = RE.IdRelacionada  
                            WHERE  
                                C.IdContrato = @Contrato  
                                AND CO_Registro.IdEstado = @Aprobado  
                                AND CO_Registro.CvTipoDocFacturacion = @TipoFactura  
                                AND ISNULL(CONVERT(INT, F.ProcesadoSIPAC), 0) = 0  
                                AND S.NombreServicio NOT LIKE '%No elegibles%'  
                                AND FCP.UUID NOT IN (  
                                                        SELECT  
                                                            UUID  
                                                        FROM  
                                                            #uuidNoReportar  
                                                    )  
                                AND FCP.UUID NOT IN (  
                                                        SELECT  
                                                            ControlF.UUID  
                                                        FROM  
                                                            dbo.FI_ControlPPDComplementos ControlF  
                                                        WHERE  
                                                            ControlF.IdContrato = @Contrato  
                                                    )  
                                AND P.IdPresupuesto = CASE  
                                                          WHEN @IdPresupuesto = 0  
                                                              THEN LPM.IdPresupuesto  
                                                          ELSE  
                                                              @IdPresupuesto  
                                                      END  
                            GROUP BY  
                                CASE  
                                    WHEN ISNULL(C.IDSIPAC, '') <> ''  
                                        THEN LTRIM(RTRIM(C.IDSIPAC))  
                                    ELSE  
                                        LTRIM(RTRIM(CON.IDSIPAC))  
                                END,  
                                LTRIM(RTRIM(C.IDRegFiducidiario)),  
                                C.NumeroContrato,  
                                CASE  
                                    WHEN len(P.IdPresupuestoCNH) > 10  
                                        THEN SUBSTRING(P.IdPresupuestoCNH, 22, 10)  
                                    ELSE  
                                        P.IdPresupuestoCNH  
                                END,  
                                MONTH(CO_Registro.MesPresentacion),  
                                YEAR(CO_Registro.MesPresentacion),  
                                ISNULL(SUBSTRING(FCP.IdDocFacturacionSIPAC, 1, 2), 'CF'),  
                                CASE  
                                    WHEN CO_Registro.CvTipoDocFacturacion = @TipoFactura  
                                        THEN ISNULL(FCP.UUID, 'NÚMERO NO REGISTRADO')  
                                    ELSE  
                                        'NA'  
                                END,  
                                LTRIM(RTRIM(APCNH.id_Actividad)),  
                                LTRIM(RTRIM(SP.[id_Sub-actividad])),  
                                LTRIM(RTRIM(TP.id_Tarea)),  
                                CASE  
                                    WHEN CO_Registro.CostosAtribuiblesAdministracion = 1  
                                        THEN 1  
                                    ELSE  
                                        0  
                                END,  
                                CASE  
                                    WHEN CO_Registro.CostosAtribuiblesAdministracion = 1  
                                        THEN 'NA'  
                                    ELSE  
                                        LTRIM(RTRIM(ISNULL(CPO.NombreCampo, '-')))  
                                END,  
                                CASE  
                                    WHEN CO_Registro.CostosAtribuiblesAdministracion = 1  
                                        THEN 'NA'  
                                    ELSE  
                                        LTRIM(RTRIM(ISNULL(Y.NombreYacimiento, '-')))  
                                END,  
                                CASE  
                                    WHEN CO_Registro.CostosAtribuiblesAdministracion = 1  
                                        THEN 'NA'  
                                    ELSE  
                                        LTRIM(RTRIM(I.NombreInstalacion))  
                                END,  
                                CASE  
                                    WHEN CO_Registro.CapexOpexEdicion IS NOT NULL  
                                        THEN CASE  
                                                 WHEN CO_Registro.CapexOpexEdicion = 1  
                                                     THEN 1  
                                                 ELSE  
                                                     2  
                                             END  
                                    ELSE  
                                        CASE  
                                            WHEN CC.Operacion = 1  
                                                THEN 1  
                                            ELSE  
                                                2  
                                        END  
                                END,  
                                CASE  
                                    WHEN ISNULL(RE.IdRelacionada, 2) <> 2  
                                        THEN 1  
                                    ELSE  
                                        2  
                                END,  
                                FCP.TipoComprobante,  
                                CC.Nivel3,  
                                CC.Descripcion,  
                                CO_Registro.Poliza,  
                                SUBSTRING(CO_Registro.Comentarios, 0, 299),  
                                TM.TipoMonedaCorto,  
                                CAST(ISNULL(TTF.TipoCambioCP, 0) AS DECIMAL(15, 4)),  
                                CASE @Plantilla  
                                    WHEN 'CGI_2022'  
                                        THEN ISNULL(CO_Registro.RegistroConAjuste, 0)  
                                    ELSE  
                                        0  
                                END,  
                                CASE @Plantilla  
                                    WHEN 'CGI_2022'  
                                        THEN ISNULL(CO_Registro.AsociadoIncrementoPMT, 0)  
                                    ELSE  
                                        0  
                                END  
                            --     
  
                            UNION  
  
                            --     
                            SELECT  
                                CASE  
                                    WHEN ISNULL(C.IDSIPAC, '') <> ''  
                                        THEN LTRIM(RTRIM(C.IDSIPAC))  
                                    ELSE  
                                        LTRIM(RTRIM(CON.IDSIPAC))  
                                END                                        AS [RF_00],  
                                LTRIM(RTRIM(C.IDRegFiducidiario))          AS [RI_00],  
                                C.NumeroContrato                           AS [RF01_01],  
                                CASE  
                                    WHEN len(P.IdPresupuestoCNH) > 10  
                                        THEN SUBSTRING(P.IdPresupuestoCNH, 22, 10)  
                                    ELSE  
                                        P.IdPresupuestoCNH  
                                END                                        AS [RC21_00],  
                                MONTH(CO_Registro.MesPresentacion)         AS [RC21_01],  
                                YEAR(CO_Registro.MesPresentacion)          AS [RC21_02],  
                                NULL                                       AS [RC21_03],  
                                SUBSTRING(PC.IdDocFacturacionSIPAC, 1, 2)  AS [RC21_04],  
                                'NA'                                       AS [RC21_05],  
                                CASE  
                                    WHEN CO_Registro.CvTipoDocFacturacion = @TipoFactura  
                                        THEN 'NA'  
                                    WHEN CO_Registro.CvTipoDocFacturacion = @TipoComprobanteExtranjero 
                                        THEN 'NA'  
                                    WHEN CO_Registro.CvTipoDocFacturacion = @TipoPedimentoImportacion  
                                        THEN PC.NumeroPedimento  
                                END                                        AS [RC21_06],  
                                CASE  
                                    WHEN CO_Registro.CvTipoDocFacturacion = @TipoFactura  
                                        THEN 'NA'  
                                    WHEN CO_Registro.CvTipoDocFacturacion = @TipoPedimentoImportacion  
                                        THEN 'NA'  
                                    WHEN CO_Registro.CvTipoDocFacturacion = @TipoComprobanteExtranjero 
                                        THEN PC.IdDocFacturacionSIPAC  
                                END                                        AS [RC21_07],  
                                'NA'                                       AS [RC21_08],  
                                'PUE'                                      AS [RC21_09],  
                                LTRIM(RTRIM(APCNH.id_Actividad))           AS [RC21_10],  
                                LTRIM(RTRIM(SP.[id_Sub-actividad]))        AS [RC21_11],  
                                LTRIM(RTRIM(TP.id_Tarea))                  AS [RC21_12],  
                                CASE  
                                    WHEN CO_Registro.CostosAtribuiblesAdministracion = 1  
                                        THEN 1  
                                    ELSE  
                                        0  
                                END                                        AS [RC21_13],  
                                CASE  
                                    WHEN CO_Registro.CostosAtribuiblesAdministracion = 1  
                                        THEN 'NA'  
                                    ELSE  
                                        LTRIM(RTRIM(ISNULL(CPO.NombreCampo, '-')))  
                                END                                        AS [RC21_14],  
                                CASE  
                                    WHEN CO_Registro.CostosAtribuiblesAdministracion = 1  
                                        THEN 'NA'  
                                    ELSE  
                                        LTRIM(RTRIM(ISNULL(Y.NombreYacimiento, '-')))  
                                END                                        AS [RC21_15],  
                                CASE  
                                    WHEN CO_Registro.CostosAtribuiblesAdministracion = 1  
                                        THEN 'NA'  
                                    ELSE  
                                        LTRIM(RTRIM(I.NombreInstalacion))  
                                END                                        AS [RC21_16],  
                                CC.Nivel3                                  AS [RC21_17],  
                                CC.Descripcion                             AS [RC21_18],  
                                CO_Registro.Poliza                         AS [RC21_19],  
                                SUBSTRING(CO_Registro.Comentarios, 0, 299) AS [RC21_20],  
                                CASE  
                                    WHEN CO_Registro.CapexOpexEdicion IS NOT NULL  
                                        THEN CASE  
                                                 WHEN CO_Registro.CapexOpexEdicion = 1  
                                                     THEN 1  
                                                 ELSE  
                                                     2  
                                             END  
                                    ELSE  
                                        CASE  
                                            WHEN CC.Operacion = 1  
                                                THEN 1  
                                            ELSE  
                                                2  
                                        END  
                                END                                        AS [RC21_21],  
                                SUM(   CASE  
                                           WHEN ISNULL(MP.MontoRegistro, 0) <> 0  
                                               THEN MP.RC2122  
                                           ELSE  
                                               0  
                                       END  
                                   )                                       AS [RC21_22],  
                                0                                          AS [RC21_23],  
                                TM.TipoMonedaCorto                         AS [RC21_24],  
                                CAST(ISNULL(MP.TCD, 0) AS DECIMAL(15, 4))             AS [RC21_25],  
                                CASE  
                                    WHEN ISNULL(RE.IdRelacionada, 2) <> 2  
                                        THEN 1  
                                    ELSE  
                                        2  
                                END                                        AS [RC21_26],  
                                CASE @Plantilla  
                                    WHEN 'CGI_2022'  
                                        THEN ISNULL(CO_Registro.RegistroConAjuste, 0)  
                                   ELSE  
                                        0  
                                END                                        AS [RC21_27],  
                                CASE @Plantilla  
                                    WHEN 'CGI_2022'  
                                        THEN ISNULL(CO_Registro.AsociadoIncrementoPMT, 0)  
                                    ELSE  
                                        0  
                                END                                        AS [RC21_28]  
                            FROM  
                                dbo.FI_Transfer                     TR WITH (NOLOCK)  
                                JOIN  
                                    dbo.FI_TransferFactura          TF WITH (NOLOCK)  
                                        ON TR.IdTransferencia = TF.IdTransfer  
                                JOIN  
                                    dbo.FI_PedimentoComprobante     PC WITH (NOLOCK)  
                                        ON TF.IdPedimentoComprobante = PC.IdPedimentoComprobante  
                                           AND PC.IdContrato = TR.IdContrato  
                                JOIN  
                                    dbo.CO_Registro WITH (NOLOCK)  
                                        ON CO_Registro.IdPedimentoComprobante = PC.IdPedimentoComprobante  
                                           AND CO_Registro.IdEstado = @Aprobado  
                                           AND CO_Registro.CvTipoDocFacturacion IN (  
                                                                                       @TipoPedimentoImportacion, @TipoComprobanteExtranjero  
                                                                                   )  
                                JOIN  
                                    dbo.CO_LineaPresupuestoMes      LPM WITH (NOLOCK)  
                                        ON CO_Registro.IdPrograma = LPM.IdLineaPresupuestoMes  
                                JOIN  
                                    dbo.CO_Presupuesto              P WITH (NOLOCK)  
                                        ON P.IdPresupuesto = LPM.IdPresupuesto  
                                JOIN  
                                    dbo.CO_AnioContractual          AC WITH (NOLOCK)  
                                        ON AC.IdAnioContractual = P.IdAnioContractual  
                                JOIN  
                                    dbo.CO_Contrato                 C WITH (NOLOCK)  
                                        ON AC.IdContrato = C.IdContrato  
                                           AND C.IdContrato = @Contrato  
                                JOIN  
                                    dbo.CO_Contratista              CON WITH (NOLOCK)  
                                        ON C.IdContratista = CON.IdContratista  
                                JOIN  
                                    dbo.CO_ActividadPetroleraCNH    APCNH WITH (NOLOCK)  
                                        ON LPM.IdActividadPetrolera = APCNH.IdActividadPetrolera  
                                JOIN  
                                    dbo.CO_SubactividadPetrolera    SP WITH (NOLOCK)  
                                        ON LPM.IdSubactividadPetrolera = SP.IdSubactividadPetrolera  
                                JOIN  
                                    dbo.CO_TareaPetrolera           TP WITH (NOLOCK)  
                                        ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera  
                                JOIN  
                                    dbo.CO_Instalacion              I WITH (NOLOCK)  
                                        ON CO_Registro.IdInstalacion = I.IdInstalacion  
                                JOIN  
                                    dbo.CO_Servicio                 S WITH (NOLOCK)  
                                        ON S.IdServicio = LPM.IdServicio  
                                           AND C.IdContrato = S.IdContrato  
								JOIN  
                                    #MontosConvertidosPedimentosCom MP  
                                        ON MP.IdRegistro = CO_Registro.IdRegistro  
                                           AND MP.IdPedimentoComprobante = CO_Registro.IdPedimentoComprobante  
                                LEFT JOIN  
                                    dbo.PD_Campo                    CPO WITH (NOLOCK)  
                                        ON I.IdCampo = CPO.IdCampo  
                                LEFT JOIN  
                                    dbo.CO_Yacimiento               Y WITH (NOLOCK)  
                                        ON CPO.IdYacimiento = Y.IdYacimiento  
                                LEFT JOIN  
                                    dbo.CO_CatalogoCuentaSH         CC WITH (NOLOCK)  
                                        ON CC.IdCatalogoCuentasSH = CO_Registro.IdCatalogoCuentasSH  
                                LEFT JOIN  
                                    dbo.PV_TipoMoneda               TM WITH (NOLOCK)  
                                        ON PC.IdMoneda = TM.IdMoneda  
                                LEFT JOIN  
                                    dbo.CO_RelacionEmpresas         RE WITH (NOLOCK)  
                                        ON RE.IdContratista = CON.IdContratista  
                                           AND PC.IdSubcontratistaExportador = RE.IdRelacionada  
                            WHERE  
                                C.IdContrato = @Contrato  
                                AND CO_Registro.IdEstado = @Aprobado  
                                AND CO_Registro.CvTipoDocFacturacion IN (  
                                                                            @TipoPedimentoImportacion, @TipoComprobanteExtranjero   
                                                                        )  
                                AND ISNULL(CONVERT(INT, PC.ProcesadoSIPAC), 0) = 0  
                                AND S.NombreServicio NOT LIKE '%No elegibles%'  
                                AND ISNULL(PC.EsnotaCredito, 0) <> 1  
                                AND P.IdPresupuesto = CASE  
                                                          WHEN @IdPresupuesto = 0  
                                                              THEN LPM.IdPresupuesto  
                                                          ELSE  
                                                              @IdPresupuesto  
                                                      END  
                            GROUP BY  
                                CASE  
                                    WHEN ISNULL(C.IDSIPAC, '') <> ''  
                                        THEN LTRIM(RTRIM(C.IDSIPAC))  
                                    ELSE  
                                        LTRIM(RTRIM(CON.IDSIPAC))  
                                END,  
                                LTRIM(RTRIM(C.IDRegFiducidiario)),  
                                C.NumeroContrato,  
                                CASE  
                                    WHEN len(P.IdPresupuestoCNH) > 10  
                                        THEN SUBSTRING(P.IdPresupuestoCNH, 22, 10)  
                                    ELSE  
                                        P.IdPresupuestoCNH  
                                END,  
                                MONTH(CO_Registro.MesPresentacion),  
                                YEAR(CO_Registro.MesPresentacion),  
                                SUBSTRING(PC.IdDocFacturacionSIPAC, 1, 2),  
                                CASE  
                                    WHEN CO_Registro.CvTipoDocFacturacion = @TipoFactura  
                                        THEN 'NA'  
                                    WHEN CO_Registro.CvTipoDocFacturacion = @TipoComprobanteExtranjero  
                                        THEN 'NA'  
                                    WHEN CO_Registro.CvTipoDocFacturacion = @TipoPedimentoImportacion  
                                        THEN PC.NumeroPedimento  
                                END,  
                                CASE  
                                    WHEN CO_Registro.CvTipoDocFacturacion = @TipoFactura  
                                        THEN 'NA'  
                                    WHEN CO_Registro.CvTipoDocFacturacion = @TipoPedimentoImportacion  
                                        THEN 'NA'  
                                    WHEN CO_Registro.CvTipoDocFacturacion = @TipoComprobanteExtranjero  
                                        THEN PC.IdDocFacturacionSIPAC  
                                END,  
                                LTRIM(RTRIM(APCNH.id_Actividad)),  
                                LTRIM(RTRIM(SP.[id_Sub-actividad])),  
                                LTRIM(RTRIM(TP.id_Tarea)),  
                                CASE  
                                    WHEN CO_Registro.CostosAtribuiblesAdministracion = 1  
                                        THEN 1  
                                    ELSE  
                                        0  
                                END,  
                                CASE  
                                    WHEN CO_Registro.CostosAtribuiblesAdministracion = 1  
                                        THEN 'NA'  
                                    ELSE  
                                        LTRIM(RTRIM(ISNULL(CPO.NombreCampo, '-')))  
                                END,  
                                CASE  
                                    WHEN CO_Registro.CostosAtribuiblesAdministracion = 1  
                                        THEN 'NA'  
                                    ELSE  
                                        LTRIM(RTRIM(ISNULL(Y.NombreYacimiento, '-')))  
                                END,  
                                CASE  
                                    WHEN CO_Registro.CostosAtribuiblesAdministracion = 1  
                                        THEN 'NA'  
                                    ELSE  
                                        LTRIM(RTRIM(I.NombreInstalacion))  
                                END,  
                                CC.Nivel3,  
                                CC.Descripcion,  
                                CO_Registro.Poliza,  
                                SUBSTRING(CO_Registro.Comentarios, 0, 299),  
                                CASE  
                                    WHEN CO_Registro.CapexOpexEdicion IS NOT NULL  
                                        THEN CASE  
                                                 WHEN CO_Registro.CapexOpexEdicion = 1  
                                                     THEN 1  
                                                 ELSE  
                                                     2  
                                             END  
                                    ELSE  
                                        CASE  
                                            WHEN CC.Operacion = 1  
                                                THEN 1  
                                            ELSE  
                                                2  
                                        END  
                                END,  
                                TM.TipoMonedaCorto,  
                                CAST(ISNULL(MP.TCD, 0) AS DECIMAL(15, 4)),  
                                CASE  
                                    WHEN ISNULL(RE.IdRelacionada, 2) <> 2  
                                        THEN 1  
                                    ELSE  
                                        2  
                                END,  
                                CASE @Plantilla  
                                    WHEN 'CGI_2022'  
                                        THEN ISNULL(CO_Registro.RegistroConAjuste, 0)  
									ELSE  
                                        0  
                                END,  
                                CASE @Plantilla  
                                    WHEN 'CGI_2022'  
                                        THEN ISNULL(CO_Registro.AsociadoIncrementoPMT, 0)  
                                    ELSE  
                                        0  
                                END;  
            END;  
  
        SELECT  
            @CuentaDeRegistros = COUNT(*)  
        FROM  
            #ResultadosGastos  
  
        IF (@CuentaDeRegistros = 0)  
            BEGIN  
                INSERT INTO #ResultadosGastos  
                    (  
                        RF_00,  
                        RI_00,  
                        RF01_01,  
                        RC21_00,  
                        RC21_01,  
                        RC21_02,  
                        RC21_03,  
                        RC21_04,  
                        RC21_05,  
                        RC21_06,  
                        RC21_07,  
                        RC21_08,  
                        RC21_09,  
                        RC21_10,  
                        RC21_11,  
                        RC21_12,  
                        RC21_13,  
                        RC21_14,  
                        RC21_15,  
                        RC21_16,  
                        RC21_17,  
                        RC21_18,  
                        RC21_19,  
                        RC21_20,  
                        RC21_21,  
                        RC21_22,  
                        RC21_23,  
                        RC21_24,  
                        RC21_25,  
                        RC21_26,  
                        RC21_27,  
                        RC21_28  
                    )  
                            SELECT DISTINCT  
                                CASE  
                                    WHEN ISNULL(CO_Contrato.IDSIPAC, '') <> ''  
                                        THEN LTRIM(RTRIM(CO_Contrato.IDSIPAC))  
                                    ELSE  
                                        LTRIM(RTRIM(CO_Contratista.IDSIPAC))  
                                END                                                AS [RF_00],  
                                LTRIM(RTRIM(CO_Contrato.IDRegFiducidiario))        AS [RI_00],  
                                LTRIM(RTRIM(CO_Contrato.NumeroContrato))           AS [RF01_01],  
                                SUBSTRING(CO_Presupuesto.IdPresupuestoCNH, 22, 10) AS [RC21_00],  
                                ''													AS [RC21_01],  
                                ''													AS [RC21_02],  
                                1                                                  AS [RC21_03],  
                                NULL                                               AS [RC21_04],  
                                NULL                                               AS [RC21_05],  
                                NULL                                               AS [RC21_06],  
                                NULL                                               AS [RC21_07],  
                                NULL                                               AS [RC21_08],  
                                NULL                                               AS [RC21_09],  
                                NULL                                               AS [RC21_10],  
                                NULL                                               AS [RC21_11],  
                                NULL                                               AS [RC21_12],  
                                NULL                                               AS [RC21_13],  
                                NULL                                               AS [RC21_14],  
                                NULL                                               AS [RC21_15],  
								NULL                                               AS [RC21_16],  
                                NULL                                               AS [RC21_17],  
                                NULL                                               AS [RC21_18],  
                                NULL                                               AS [RC21_19],  
                                NULL                                               AS [RC21_20],  
                                NULL                                               AS [RC21_21],  
                                0                                                  AS [RC21_22],  
                                0                                                  AS [RC21_23],  
                                NULL                                               AS [RC21_24],  
                                NULL                                               AS [RC21_25],  
                                NULL                                               AS [RC21_26],  
                                0                                                  AS [RC21_27],  
                                0                                                  AS [RC21_28]  
                            FROM  
                                dbo.CO_Contrato WITH (NOLOCK)  
                                JOIN  
                                    dbo.CO_Contratista WITH (NOLOCK)  
                                        ON CO_Contrato.IdContratista = CO_Contratista.IdContratista  
                                           AND CO_Contrato.IdContrato = @Contrato  
                                JOIN  
                                    dbo.CO_AnioContractual WITH (NOLOCK)  
                                        ON CO_Contrato.IdContrato = CO_AnioContractual.IdContrato  
                                JOIN  
                                    dbo.CO_Presupuesto WITH (NOLOCK)  
                                        ON CO_AnioContractual.IdAnioContractual = CO_Presupuesto.IdAnioContractual  
                            WHERE  
                                CO_Contrato.IdContrato = @Contrato  
                                AND SUBSTRING(ISNULL(CO_Presupuesto.IdPresupuestoCNH, ''), 22, 10) <> ''  
                                AND CO_Presupuesto.IdPresupuesto = CASE  
                                                                       WHEN @IdPresupuesto = 0  
                                                                           THEN CO_Presupuesto.IdPresupuesto  
                                                                       ELSE  
                                                                           @IdPresupuesto  
                                                                   END;  
            END;  
  
        IF (@Plantilla = 'CGI_2022')  
            BEGIN  
                SELECT  
                    RF_00,  
                    RI_00,  
                    RF01_01,  
                    RC21_00,  
                    RC21_01,  
                    RC21_02,  
                    ROW_NUMBER() OVER (ORDER BY  
                                           RC21_02, RC21_01,RC21_11 ASC  
                                      ) AS [RC21_03],  
                    RC21_04,  
                    RC21_05,  
                    RC21_06,  
                    RC21_07,  
                    RC21_08,  
                    RC21_09,  
                    RC21_10,  
                    RC21_11,  
                    RC21_12,  
                    RC21_13,  
                    RC21_14,  
                    RC21_15,  
                    RC21_16,  
                    RC21_17,  
                    RC21_18,  
                    RC21_19,  
                    RC21_20,  
                    RC21_21,  
                    RC21_22,  
                    RC21_23,  
                    RC21_24,  
                    RC21_25,  
                    RC21_26,  
                    RC21_27,  
                    RC21_28  
            FROM  
                    #ResultadosGastos;  
            END  
        ELSE  
            BEGIN  
                SELECT  
                    RF_00,  
                    RI_00,  
                    RF01_01,  
                    RC21_00,  
                    RC21_01,  
                    RC21_02,  
                    ROW_NUMBER() OVER (ORDER BY  
                                           RC21_02, RC21_01,RC21_11 ASC 
                                      ) AS [RC21_03],  
                    RC21_04,  
                    RC21_05,  
                    RC21_06,  
                    RC21_07,  
                    RC21_08,  
                    RC21_09,  
                    RC21_10,  
                    RC21_11,  
                    RC21_12,  
                    RC21_13,  
                    RC21_14,  
                    RC21_15,  
                    RC21_16,  
                    RC21_17,  
                    RC21_18,  
                    RC21_19,  
                    RC21_20,  
                    RC21_21,  
                    RC21_22,  
                    RC21_23,  
                    RC21_24,  
                    RC21_25,  
                    RC21_26  
                FROM  
                    #ResultadosGastos;  
            END  
    END;