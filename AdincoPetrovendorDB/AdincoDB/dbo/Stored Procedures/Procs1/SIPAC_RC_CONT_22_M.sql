
-- =============================================  
-- Author: Yazmin Glez.  
-- Create date: 2017-11-28  
-- Description: Reporte de CGI - Registro de costos. Plantilla antes RC_CONT_02_M actual RC_CONT_22_M  
-- Modificado: Manuel Cruz  
-- Fecha Modificado: 2019-06-28  
-- Description: Cambio de consulta para mostrar los complementos de pago relacionadolos al gasto  
-- Modificado:       Neri Del Angel  
-- Fecha Modificado: 2020-01-13  
-- Description:     *Agregar Validacion de @IdPresupuesto = 0  
--                  *Agregar WITH (NOLOCK) en las tablas   
-- Modificado:       Neri Del Angel  
-- Fecha Modificado: 2022-02-25  
-- Description:     *Se excluyen los E  
-- =============================================  
-- Modificado:       Reyna Olvera  
-- Fecha Modificado: 2022-08-18  
-- Description:      Se ajusta la consulta de la hoja 21 para poder retornar la snuevas columnas de la plantilla  2022 EPT y ajuste de gasto  
-- Se agrega mejoras de deuda tecnica  
-- =============================================  
-- Modificado:       Neri del Angel  
-- Fecha Modificado: 16 de Febrero del 2023  
-- Description:      Se agrega la opción obtener el nuevo campo IDSIPAC desde la tabla CO_Contrato, si este viene vacío o nulo se obtendrá desde la tabla que ya se obtenía anteriormente CO_Contratista  
-- =============================================  
-- Modificado:       Reyna Olvera  
-- Fecha Modificado: 2022-08-18  
-- Description:      SE MODIFICA LA CONSULTA POR DEUDA TECNICA, SE MODIFICA LOS JOINS Y LEFT JOIS DE UBICACIÓN, SE QUITAN ALGUNOS ALIAS  
-- =============================================  
-- Modificado:       Neri del Angel  
-- Fecha Modificado: 13 de Abril del 2023  
-- Description:      Se agrega que si el tipocambio de la tabla CO_TipoCambioDiario es nulo se muestre como 0 para identificar en el reporte que el tipo cambio no se encuentra agregado
-- ============================================= 
CREATE PROCEDURE [dbo].[SIPAC_RC_CONT_22_M]  
    @Contrato      INT,  
    @Mes           DATE,  
    @IdPresupuesto INT          = 0,  
    @Plantilla     VARCHAR(150) = ''  
AS  
    BEGIN  
        SET NOCOUNT ON;  
  
  
        /*Generar nombre de archivos*/ 
		-- Ya se ejecuta en la hoja 21
        --EXEC [SIPAC_RC_CONT_22_M_IdDoc]  
        --    @Contrato,  
        --    @Mes,  
        --    @IdPresupuesto;  
		
		DECLARE @Aprobado INT = 10004,
		@TipoFactura INT = 1,
		@TipoComplementoPago INT = 6

        /*Todas las facturas relacionadas a un gasto sin importar pago*/  
        IF OBJECT_ID('tempdb..#Facturas', 'U') IS NOT NULL  
            DROP TABLE #Facturas;  
        IF OBJECT_ID('tempdb..#MontosTotalTransferencia', 'U') IS NOT NULL  
            DROP TABLE #MontosTotalTransferencia;  
        IF OBJECT_ID('tempdb..#uuidNoReportar', 'U') IS NOT NULL  
            DROP TABLE #uuidNoReportar;  
		
		DECLARE @IDSIPAC VARCHAR(4000)

		SELECT @IDSIPAC = CO_Contratista.IDSIPAC
		FROM CO_Contratista WITH (NOLOCK)  
			INNER JOIN CO_Contrato 
				ON CO_Contrato.IdContrato = @Contrato
				AND CO_Contrato.IdContratista = CO_Contratista.IdContratista

        CREATE TABLE #Facturas  
            (  
                IdFactura       INT,  
                UUID            VARCHAR(2000),  
                TipoComprobante VARCHAR(50),  
                MetodoPago      VARCHAR(50),
				IdMoneda		INT,
				ProcesadoSIPAC	BIT,
				MontoConIva		MONEY,
				IdContrato		INT,
				ArchivoXML		VARCHAR(8000),
				SubTotal		MONEY,
				Descuento		MONEY,
				TotalImpuestosRetenidos MONEY,
				Fecha			DATETIME,
				Emisor			VARCHAR(4000),
				LugarExpedicion	VARCHAR(4000),
				Receptor		VARCHAR(4000)
            );  
  
        /*Montos Pagados*/  
        CREATE TABLE #MontosTotalTransferencia  
            (  
                IdFactura        INT,  
                UUID             VARCHAR(2000),  
                FormaPago        NVARCHAR(50),  
                IdMonedaFactura  INT,  
                MetodoPago       NVARCHAR(50),  
                IdMonedaTransfer INT,  
                TipoCambio       FLOAT,  
                RC2209           FLOAT,  
                NoParcialidad    INT  
            );  
  
        CREATE TABLE #uuidNoReportar (UUID VARCHAR(2000));  
		CREATE TABLE #FacturaHash(IdFactura INT, HashSHA256 NVARCHAR(600))


        INSERT INTO #Facturas  
            (  
                IdFactura,  
                UUID,  
                TipoComprobante,  
                MetodoPago,
				IdMoneda,
				ProcesadoSIPAC,
				MontoConIva,
				IdContrato,
				ArchivoXML,
				SubTotal,
				Descuento,
				TotalImpuestosRetenidos,
				Fecha,
				Emisor,
				LugarExpedicion,
				Receptor
            )  
                    SELECT  
                        FI_Factura.IdFactura,  
                        FI_Factura.UUID,  
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
                        END AS TipoComprobante,  
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
                        END AS MetodoPago,  
						FI_Factura.IdMoneda, 
						FI_Factura.ProcesadoSIPAC,
						FI_Factura.MontoConIva,
						FI_Factura.IdContrato,
						FI_Factura.ArchivoXML,
						FI_Factura.SubTotal,
						FI_Factura.Descuento,
						FI_Factura.TotalImpuestosRetenidos,
						FI_Factura.Fecha,
						FI_Factura.Emisor,
						FI_Factura.LugarExpedicion,
						FI_Factura.Receptor
                    FROM  
                        dbo.CO_Registro WITH (NOLOCK)  
                        JOIN  
                            dbo.FI_Factura WITH (NOLOCK)  
                                ON CO_Registro.IdFactura = FI_Factura.IdFactura  
                        JOIN  
                            dbo.CO_LineaPresupuestoMes WITH (NOLOCK)  
                                ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes  
                        JOIN  
                            dbo.CO_Presupuesto WITH (NOLOCK)  
                                ON CO_Presupuesto.IdPresupuesto = CO_LineaPresupuestoMes.IdPresupuesto  
                        JOIN  
                            dbo.CO_AnioContractual WITH (NOLOCK)  
                                ON CO_AnioContractual.IdAnioContractual = CO_Presupuesto.IdAnioContractual  
                                   AND CO_AnioContractual.IdContrato = @Contrato  
                        JOIN  
                            dbo.CO_Contrato WITH (NOLOCK)  
                                ON CO_AnioContractual.IdContrato = CO_Contrato.IdContrato  
                                   AND CO_AnioContractual.IdContrato = @Contrato  
                                   AND CO_Contrato.IdContrato = @Contrato  
                        JOIN  
                            dbo.CO_Servicio WITH (NOLOCK)  
                                ON CO_Servicio.IdServicio = CO_LineaPresupuestoMes.IdServicio   
                    WHERE  
                        CO_Contrato.IdContrato = @Contrato  
                        AND DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1) = @Mes  
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
                        FI_Factura.IdFactura,  
                        FI_Factura.UUID,
						FI_Factura.IdMoneda, 
						FI_Factura.ProcesadoSIPAC,
						FI_Factura.MontoConIva,
						FI_Factura.IdContrato,
						FI_Factura.ArchivoXML,
						FI_Factura.SubTotal,
						FI_Factura.Descuento,
						FI_Factura.TotalImpuestosRetenidos,
						FI_Factura.Fecha,
						FI_Factura.Emisor,
						FI_Factura.LugarExpedicion,
						FI_Factura.Receptor
  
		
		INSERT INTO #FacturaHash(IdFactura, HashSHA256)	
		SELECT FI_ArchivoXml.IdFactura, FI_ArchivoXml.HashSHA256
		FROM #Facturas
		INNER JOIN FI_ArchivoXml
			ON #Facturas.IdFactura = FI_ArchivoXml.IdFactura
		UNION		
		SELECT FI_ArchivoXml.IdFactura, FI_ArchivoXml.HashSHA256 
		FROM #Facturas
		INNER JOIN FI_Factura FCPDR WITH (NOLOCK)  
                ON #Facturas.IdFactura = FCPDR.IdFactura 
		INNER JOIN FI_CPDocRelacionado WITH (NOLOCK)  
                ON FCPDR.UUID = FI_CPDocRelacionado.IdDocumento
		INNER JOIN FI_ComplementoDePago WITH (NOLOCK)  
                ON FI_CPDocRelacionado.IdComplementoDePago = FI_ComplementoDePago.IdComplementoDePago
		INNER JOIN FI_ArchivoXml
			ON FI_ComplementoDePago.IdFactura = FI_ArchivoXml.IdFactura
		WHERE #Facturas.MetodoPago = 'PPD'
		GROUP BY FI_ArchivoXml.IdFactura, FI_ArchivoXml.HashSHA256

        --  
        INSERT INTO #MontosTotalTransferencia  
            (  
                IdFactura,  
                UUID,  
                FormaPago,  
                IdMonedaFactura,  
                MetodoPago,  
                IdMonedaTransfer,  
                TipoCambio,  
                RC2209,  
                NoParcialidad  
            )  
                    SELECT  
                        #Facturas.IdFactura,  
                        #Facturas.UUID,  
                        PV_MetodoPago.C_FormaPago                                AS FormaPago,  
                        #Facturas.IdMoneda,  
                        #Facturas.MetodoPago                                     AS MetodoPago,  
                        FI_Transfer.IdMoneda,  
                        ISNULL(CO_TipoCambioDiario.TipoCambio, 0),  
                        CAST(ROUND(#Facturas.MontoConIva, 2) AS DECIMAL(15, 2)) AS RC2209,  
                        0       AS NoParcialidad  
                    FROM #Facturas
						INNER JOIN dbo.FI_TransferFactura WITH (NOLOCK)  
                                ON FI_TransferFactura.CvTipoDocFacturacion = @TipoFactura  
                                   AND FI_TransferFactura.IdFactura = #Facturas.IdFactura
								   AND #Facturas.MetodoPago = 'PUE'  
						INNER JOIN dbo.FI_Transfer WITH (NOLOCK)  
								ON FI_TransferFactura.IdTransfer = FI_Transfer.IdTransferencia
								AND FI_Transfer.IdContrato = @Contrato  
                        INNER JOIN  
                            dbo.PV_MetodoPago WITH (NOLOCK)  
                                ON FI_Transfer.IdMetodoPago = PV_MetodoPago.IdMetodoPago  
                        LEFT JOIN  
                            dbo.CO_TipoCambioDiario WITH (NOLOCK)  
                                ON CO_TipoCambioDiario.IdMoneda = FI_Transfer.IdMoneda  
                                   AND FI_Transfer.IdMoneda <> #Facturas.IdMoneda  
                                   AND DAY(CO_TipoCambioDiario.Fecha) = DAY(FI_Transfer.FechaPago)  
                                   AND MONTH(CO_TipoCambioDiario.Fecha) = MONTH(FI_Transfer.FechaPago)  
                                   AND YEAR(CO_TipoCambioDiario.Fecha) = YEAR(FI_Transfer.FechaPago)  
                    WHERE  
                        ISNULL(CONVERT(INT, #Facturas.ProcesadoSIPAC), 0) = 0  
                        AND #Facturas.MetodoPago = 'PUE'  
                        AND FI_Transfer.IdContrato = @Contrato  
						AND FI_TransferFactura.CvTipoDocFacturacion = @TipoFactura  
                    GROUP BY  
                        CAST(ROUND(#Facturas.MontoConIva, 2) AS DECIMAL(15, 2)),  
                        #Facturas.IdFactura,  
                        #Facturas.UUID,  
                        #Facturas.MetodoPago,  
                        #Facturas.IdMoneda,  
                        PV_MetodoPago.C_FormaPago,  
                        FI_Transfer.IdMoneda,  
                        ISNULL(CO_TipoCambioDiario.TipoCambio, 0)
                    --  
                    UNION  
                    --  
                    SELECT  
                        FCPDR.IdFactura,  
                        FI_CPDocRelacionado.IdDocumento,  
                        '99'               AS FormaPago,  
                        PV_TipoMoneda.IdMoneda,  
                        CASE  
                            WHEN FI_CPDocRelacionado.MetodoDePagoDR IS NULL  
                                THEN FCPDR.MetodoPago  
                            ELSE  
                                FI_CPDocRelacionado.MetodoDePagoDR  
                        END                AS MetodoPago,  
                        FI_Transfer.IdMoneda,  
                        MAX(ISNULL(CO_TipoCambioDiario.TipoCambio, 0)),  
                        0,  
                        0  
                    FROM  
                        dbo.FI_Transfer WITH (NOLOCK)  
                        JOIN  
                            dbo.FI_TransferFactura WITH (NOLOCK)  
                                ON FI_Transfer.IdTransferencia = FI_TransferFactura.IdTransfer  
                                   AND FI_TransferFactura.CvTipoDocFacturacion = @TipoComplementoPago  
                                   AND FI_Transfer.IdContrato = @Contrato  
                        JOIN  
                            dbo.FI_ComplementoDePago WITH (NOLOCK)  
                                ON FI_TransferFactura.IdFactura = FI_ComplementoDePago.IdFactura  
                        JOIN  
                            dbo.FI_CPDocRelacionado WITH (NOLOCK)  
                                ON FI_ComplementoDePago.IdComplementoDePago = FI_CPDocRelacionado.IdComplementoDePago  
						JOIN  
                            dbo.FI_Factura WITH (NOLOCK)  
                                ON FI_ComplementoDePago.IdFactura = FI_Factura.IdFactura  
                        JOIN  
                            FI_Factura FCPDR WITH (NOLOCK)  
                                ON FI_CPDocRelacionado.IdDocumento = FCPDR.UUID  
                                   AND FI_Factura.IdContrato = FCPDR.IdContrato  
                        JOIN  
                            dbo.PV_TipoMoneda WITH (NOLOCK)  
                                ON FI_CPDocRelacionado.MonedaDR = PV_TipoMoneda.TipoMonedaCorto  
                        JOIN  
                            #Facturas  
                                ON #Facturas.IdFactura = FCPDR.IdFactura  
                                   AND #Facturas.MetodoPago = 'PPD'  
                        LEFT JOIN  
                            dbo.CO_TipoCambioDiario WITH (NOLOCK)  
                                ON CO_TipoCambioDiario.IdMoneda = FI_Transfer.IdMoneda  
                                   AND FI_Transfer.IdMoneda <> FCPDR.IdMoneda  
                                   AND DAY(CO_TipoCambioDiario.Fecha) = DAY(FI_Transfer.FechaPago)  
                                   AND MONTH(CO_TipoCambioDiario.Fecha) = MONTH(FI_Transfer.FechaPago)  
                                   AND YEAR(CO_TipoCambioDiario.Fecha) = YEAR(FI_Transfer.FechaPago)  
                    WHERE  
                        FI_Transfer.IdContrato = @Contrato  
                        AND ISNULL(CONVERT(INT, FCPDR.ProcesadoSIPAC), 0) = 0  
                        AND #Facturas.MetodoPago = 'PPD'  
                        AND FI_TransferFactura.CvTipoDocFacturacion = @TipoComplementoPago  
                    GROUP BY  
                        FCPDR.IdFactura,  
                        FI_CPDocRelacionado.IdDocumento,  
                        PV_TipoMoneda.IdMoneda,  
                        CASE  
                            WHEN FI_CPDocRelacionado.MetodoDePagoDR IS NULL  
                                THEN FCPDR.MetodoPago  
                            ELSE  
                                FI_CPDocRelacionado.MetodoDePagoDR  
                        END,  
                        FI_Transfer.IdMoneda;  
  
        /*Omitir facturas en la hoja 22*/  
        IF (@Mes = '20190801')  
            BEGIN  
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
            END;  
        IF (@Mes <> '20190901')  
            BEGIN  
                INSERT INTO #uuidNoReportar  
                    (  
                        UUID  
                    )  
                VALUES  
                    (  
                        '9A159442-52BC-1E49-8190-D020953CE967'  
                    );  
            END;  
        IF (@Mes <> '20200101')  
            BEGIN  
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
            END;  
        IF (@Mes = '20200501')  
            BEGIN  
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
            END;  
  
        /*Consulta final quue llena la hoja 22 de la plantilla*/  
  
        SELECT  
            CASE  
                WHEN ISNULL(CO_Contrato.IDSIPAC, '') <> ''  
                    THEN LTRIM(RTRIM(CO_Contrato.IDSIPAC))  
                ELSE  
                    LTRIM(RTRIM(@IDSIPAC))  
            END																		AS [RF_00],  
            LTRIM(RTRIM(CO_Contrato.IDRegFiducidiario))								AS [RI_00],  
            CO_Contrato.NumeroContrato												AS [RF01_01],  
            MONTH(CO_Registro.MesPresentacion)										AS [RC21_01],  
            YEAR(CO_Registro.MesPresentacion)										AS [RC21_02],  
            REPLACE(#Facturas.ArchivoXML, '-', '_')									AS [RC22_02],  
            #FacturaHash.HashSHA256														AS [RC22_03],  
            #Facturas.UUID															AS [RC22_04],  
            #Facturas.TipoComprobante												AS [RC22_05],  
            #MontosTotalTransferencia.MetodoPago									AS [RC22_06],  
            CAST(ROUND(#Facturas.MontoConIva, 2) AS DECIMAL(15, 2))					AS [RC22_07],  
            CAST(ROUND(  
                          ISNULL(#Facturas.SubTotal, 0)  
                          - (ISNULL(#Facturas.Descuento, 0) + ISNULL(#Facturas.TotalImpuestosRetenidos, 0)), 2  
                      ) AS DECIMAL(15, 2))											AS [RC22_08],  
            #MontosTotalTransferencia.RC2209										AS [RC22_09],  
            #MontosTotalTransferencia.NoParcialidad									AS [RC22_10],  
            #MontosTotalTransferencia.FormaPago										AS [RC22_11],  
            CAST(#Facturas.Fecha AS DATE)											AS [RC22_12],  
            SUBSTRING(LTRIM(RTRIM((#Facturas.Emisor))), 0, 13)						AS [RC22_13],  
            SUBSTRING(LTRIM(RTRIM(ISNULL(#Facturas.LugarExpedicion, ''))), 0, 30)	AS [RC22_14],  
            LTRIM(RTRIM(#Facturas.Receptor))										AS [RC22_15],  
            PV_TipoMoneda.TipoMonedaCorto											AS [RC22_16],  
            2																		AS [RC22_17]  
        FROM #MontosTotalTransferencia
		INNER JOIN #Facturas
			ON #Facturas.TipoComprobante NOT IN ( 'E' )
				AND #MontosTotalTransferencia.IdFactura = #Facturas.IdFactura
		INNER JOIN  
                dbo.CO_Registro WITH (NOLOCK)  
                    ON CO_Registro.IdEstado = @Aprobado
					AND CO_Registro.CvTipoDocFacturacion = @TipoFactura
					AND #Facturas.IdFactura = CO_Registro.IdFactura                  
            JOIN  
                dbo.CO_LineaPresupuestoMes WITH (NOLOCK)  
                    ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes  
            JOIN  
                dbo.CO_Presupuesto WITH (NOLOCK)  
                    ON CO_LineaPresupuestoMes.IdPresupuesto = CO_Presupuesto.IdPresupuesto     		
            JOIN  
             dbo.CO_AnioContractual WITH (NOLOCK)  
                    ON CO_AnioContractual.IdAnioContractual = CO_Presupuesto.IdAnioContractual  
            JOIN  
                dbo.CO_Contrato WITH (NOLOCK)  
                    ON CO_AnioContractual.IdContrato = CO_Contrato.IdContrato  
                       AND CO_Contrato.IdContrato = @Contrato  
			JOIN  
                dbo.CO_Servicio WITH (NOLOCK)  
                    ON CO_Servicio.IdContrato = @Contrato   
					AND CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
            INNER JOIN  
                dbo.PV_TipoMoneda WITH (NOLOCK)  
                    ON #Facturas.IdMoneda = PV_TipoMoneda.IdMoneda  
			LEFT JOIN  
					#FacturaHash  
                    ON #Facturas.IdFactura = #FacturaHash.IdFactura
        WHERE  
            CO_Contrato.IdContrato = @Contrato  
            AND DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1) = @Mes  
            AND CO_Registro.IdEstado = @Aprobado  
            AND CO_Registro.CvTipoDocFacturacion = @TipoFactura  
            AND ISNULL(CONVERT(INT, #Facturas.ProcesadoSIPAC), 0) = 0  
            AND CO_Servicio.NombreServicio NOT LIKE '%No elegibles%'  
            AND #Facturas.UUID NOT IN (  
                                           SELECT  
                                               RPT.UUID  
                                           FROM  
                                               #uuidNoReportar RPT  
                                       )  
            AND #Facturas.UUID NOT IN (  
                                           SELECT  
                                               ControlF.UUID  
                                           FROM  
                                               dbo.FI_ControlPPDComplementos ControlF  
                                           WHERE  
                                               ControlF.IdContrato = @Contrato  
                                       )  
            AND CO_Presupuesto.IdPresupuesto = CASE  
                                                   WHEN @IdPresupuesto = 0  
                                                       THEN CO_LineaPresupuestoMes.IdPresupuesto  
                                                   ELSE  
                                                       @IdPresupuesto  
                                               END  
        GROUP BY  
            CO_Contrato.IDSIPAC,   
            LTRIM(RTRIM(CO_Contrato.IDRegFiducidiario)),  
            CO_Contrato.NumeroContrato,  
            MONTH(CO_Registro.MesPresentacion),  
            YEAR(CO_Registro.MesPresentacion),  
            REPLACE(#Facturas.ArchivoXML, '-', '_'),
			#FacturaHash.HashSHA256,
            #Facturas.UUID,  
            #Facturas.TipoComprobante,  
            #MontosTotalTransferencia.MetodoPago,  
            CAST(ROUND(#Facturas.MontoConIva, 2) AS DECIMAL(15, 2)),  
            CAST(ROUND(  
                          ISNULL(#Facturas.SubTotal, 0)  
                          - (ISNULL(#Facturas.Descuento, 0) + ISNULL(#Facturas.TotalImpuestosRetenidos, 0)), 2  
                      ) AS DECIMAL(15, 2)),  
            #MontosTotalTransferencia.RC2209,  
            #MontosTotalTransferencia.NoParcialidad,  
            #MontosTotalTransferencia.FormaPago,  
            CAST(#Facturas.Fecha AS DATE),  
            SUBSTRING(LTRIM(RTRIM((#Facturas.Emisor))), 0, 13),  
            SUBSTRING(LTRIM(RTRIM(ISNULL(#Facturas.LugarExpedicion, ''))), 0, 30),  
            LTRIM(RTRIM(#Facturas.Receptor)),  
            PV_TipoMoneda.TipoMonedaCorto
        --  
        UNION  
        --  
         SELECT  
            CASE  
                WHEN ISNULL(CO_Contrato.IDSIPAC, '') <> ''  
                    THEN LTRIM(RTRIM(CO_Contrato.IDSIPAC))  
                ELSE  
                    LTRIM(RTRIM(@IDSIPAC))  
            END                                                             AS [RF_00],  
            LTRIM(RTRIM(CO_Contrato.IDRegFiducidiario))                     AS [RI_00],  
            CO_Contrato.NumeroContrato                                      AS [RF01_01],  
            MONTH(CO_Registro.MesPresentacion)                              AS [RC21_01],  
            YEAR(CO_Registro.MesPresentacion)                               AS [RC21_02],  
            REPLACE(FCP.ArchivoXML, '-', '_')                               AS [RC22_02],  
            #FacturaHash.HashSHA256                                         AS [RC22_03],  
            FCP.UUID                                                        AS [RC22_04],  
            'P'                                                             [RC22_05],  
            'PPD'                                                           AS [RC22_06],  
            MAX(FI_ComplementoDePago.Monto)                                 AS [RC22_07],  
            MAX(FI_ComplementoDePago.Monto)                                 AS [RC22_08],  
            MAX(FI_ComplementoDePago.Monto)                                 AS [RC22_09],  
            MAX(FI_CPDocRelacionado.NumParcialidad)                         AS [RC22_10],  
            FI_ComplementoDePago.FormaDePagoP                               AS [RC22_11], --'03'  
  
            CAST(FCP.Fecha AS DATE)                                         AS [RC22_12],  
            SUBSTRING(LTRIM(RTRIM((FCP.Emisor))), 0, 13)                    AS [RC22_13],  
            SUBSTRING(LTRIM(RTRIM(ISNULL(FCP.LugarExpedicion, ''))), 0, 30) AS [RC22_14],  
            LTRIM(RTRIM(FCP.Receptor))                                      AS [RC22_15],  
            FI_ComplementoDePago.MonedaP                                    AS [RC22_16],  
            2                                                               AS [RC22_17]  
        FROM  
            dbo.FI_Transfer WITH (NOLOCK)  
            JOIN  
                dbo.FI_TransferFactura WITH (NOLOCK)  
                    ON FI_Transfer.IdTransferencia = FI_TransferFactura.IdTransfer  
                       AND FI_Transfer.IdContrato = @Contrato  
            JOIN  
                dbo.FI_ComplementoDePago WITH (NOLOCK)  
                    ON FI_TransferFactura.IdFactura = FI_ComplementoDePago.IdFactura  
            JOIN  
                dbo.FI_CPDocRelacionado WITH (NOLOCK)  
                    ON FI_CPDocRelacionado.IdComplementoDePago = FI_ComplementoDePago.IdComplementoDePago  
            JOIN  
                dbo.FI_Factura FCP WITH (NOLOCK)  
                    ON FI_TransferFactura.IdFactura = FCP.IdFactura  
            JOIN  
                dbo.FI_Factura FCPDR WITH (NOLOCK)  
                    ON FI_CPDocRelacionado.IdDocumento = FCPDR.UUID  
            JOIN  
                dbo.CO_Registro WITH (NOLOCK)  
                    ON CO_Registro.IdFactura = FCPDR.IdFactura  
                       AND CO_Registro.IdEstado = @Aprobado  
                       AND CO_Registro.CvTipoDocFacturacion = @TipoFactura  
            JOIN  
                dbo.CO_LineaPresupuestoMes WITH (NOLOCK)  
                    ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes  
            JOIN  
                dbo.CO_Presupuesto WITH (NOLOCK)  
                    ON CO_Presupuesto.IdPresupuesto = CO_LineaPresupuestoMes.IdPresupuesto  
            JOIN  
                dbo.CO_AnioContractual WITH (NOLOCK)  
                    ON CO_AnioContractual.IdAnioContractual = CO_Presupuesto.IdAnioContractual  
            JOIN  
                dbo.CO_Contrato WITH (NOLOCK)  
                    ON CO_AnioContractual.IdContrato = CO_Contrato.IdContrato  
                AND CO_Contrato.IdContrato = @Contrato    
            JOIN  
                dbo.CO_Servicio WITH (NOLOCK)  
                    ON CO_Servicio.IdServicio = CO_LineaPresupuestoMes.IdServicio  
                       AND CO_Servicio.IdContrato = CO_Contrato.IdContrato  
            LEFT JOIN  
					#FacturaHash WITH (NOLOCK)  
                    ON FCP.IdFactura = #FacturaHash.IdFactura   
        WHERE  
            CO_Contrato.IdContrato = @Contrato  
            AND FI_Transfer.IdContrato = @Contrato  
            AND DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1) = @Mes  
            AND CO_Registro.IdEstado = @Aprobado  
            AND CO_Registro.CvTipoDocFacturacion = @TipoFactura  
            AND ISNULL(CONVERT(INT, FCP.ProcesadoSIPAC), 0) = 0  
            AND CO_Servicio.NombreServicio NOT LIKE '%No elegibles%'  
            AND FCP.UUID NOT IN (  
                                    SELECT  
                                        RPT.UUID  
                                    FROM  
                                        #uuidNoReportar RPT  
                                )  
            AND FCP.UUID NOT IN (  
                                    SELECT  
                                        ControlF.UUID  
                                    FROM  
                                        dbo.FI_ControlPPDComplementos ControlF  
                                    WHERE  
                                        ControlF.IdContrato = @Contrato  
                                )  
            AND CO_Presupuesto.IdPresupuesto = CASE  
                                                   WHEN @IdPresupuesto = 0  
                                                       THEN CO_LineaPresupuestoMes.IdPresupuesto  
                                                   ELSE  
                                                       @IdPresupuesto  
                                               END  
        GROUP BY  
			CO_Contrato.IDSIPAC,  
            LTRIM(RTRIM(CO_Contrato.IDRegFiducidiario)),  
            CO_Contrato.NumeroContrato,  
            MONTH(CO_Registro.MesPresentacion),  
            YEAR(CO_Registro.MesPresentacion),  
            REPLACE(FCP.ArchivoXML, '-', '_'),  
            #FacturaHash.HashSHA256,  
            FCP.UUID,  
            FI_ComplementoDePago.FormaDePagoP,  
            CAST(FCP.Fecha AS DATE),  
            SUBSTRING(LTRIM(RTRIM((FCP.Emisor))), 0, 13),  
            SUBSTRING(LTRIM(RTRIM(ISNULL(FCP.LugarExpedicion, ''))), 0, 30),  
            LTRIM(RTRIM(FCP.Receptor)),  
            FI_ComplementoDePago.MonedaP;  
  
    END;