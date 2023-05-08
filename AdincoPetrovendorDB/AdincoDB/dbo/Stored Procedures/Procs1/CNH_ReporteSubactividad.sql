-- CNH_ReporteSubactividad 10038,'20210101','20211231'
CREATE PROC [dbo].[CNH_ReporteSubactividad]
@pIdContrato INT,
@pDel DATETIME,
@pAl DATETIME
AS
	
IF OBJECT_ID('tempdb.dbo.#TMP_Gastos') IS NOT NULL DROP TABLE #TMP_Gastos
IF OBJECT_ID('tempdb.dbo.#TMPPedimentos') IS NOT NULL DROP TABLE #TMPPedimentos
IF OBJECT_ID('tempdb.dbo.#TMP_Facturas') IS NOT NULL DROP TABLE #TMP_Facturas
IF OBJECT_ID('tempdb.dbo.#TMPTransferenciasFactura_Pagos') IS NOT NULL DROP TABLE #TMPTransferenciasFactura_Pagos


CREATE TABLE #TMP_Gastos(IdGasto INT,IdPedimento INT,IdFactura INT)

CREATE TABLE #TMP_Facturas(	IdFactura INT,					IdSubcontratista INT,						MontoConIVAMXN decimal(14,3), 
							UUID VARCHAR(500),				FormaPago VARCHAR(200),						MetodoPago varchar(500) NULL,				NumPagos INT NULL,
							UltimaPArcialidad VARCHAR(50) NULL,	FolioFiscalAsociado VARCHAR(200) NULL,	IdMoneda INT NULL,
							Fecha DATETIME,				MontoOriginal decimal(14,3),					Moneda  VARCHAR(100))

CREATE TABLE #TMPPedimentos(IdPedimientoComprobante INT,		ImporteTotalMXN decimal(14,3),		IdSubcontratista INT,
							FormaPago VARCHAR(200),				Folio VARCHAR(50) NULL,				IdMoneda INT NULL,
							Fecha DATETIME,						ImporteTotalOrig  decimal(14,3),	Moneda  VARCHAR(100))

CREATE TABLE #TMPTransferenciasFactura_Pagos(IdFactura INT,ImporteTotal decimal(14,3),FechaPago DATETIME NULL,EsComplemento BIT,IdPedimento INT NULL,IdMoneda INT , ImporteOriginal decimal(14,3))

CREATE TABLE #TRANSFERENCIA
         (IdTransfer INT, 
          UUID       VARCHAR(500),
		  MetodoPago VARCHAR(500)
         );

--UNIVERSO DE GASTOS A CONSIDERAR EN LA CONSULTA
INSERT INTO #TMP_Gastos(IdGasto,IdPedimento,IdFactura)
SELECT IdRegistro,CO_Registro.IdPedimentoComprobante,CO_Registro.IdFactura
FROM CO_Registro 
LEFT JOIN FI_Factura ON FI_Factura.IdFactura = CO_Registro.IdFactura AND FI_Factura.IdContrato = @pIdContrato
LEFT JOIN FI_PedimentoComprobante ON FI_PedimentoComprobante.IdPedimentoComprobante = CO_Registro.IdPedimentoComprobante AND FI_PedimentoComprobante.IdContrato = @pIdContrato
WHERE CONVERT(VARCHAR,CO_Registro.InicioEjecucion,112) BETWEEN CONVERT(VARCHAR,@pDel,112) AND CONVERT(VARCHAR,@pAl,112)  AND
(FI_Factura.IdFactura IS NOT NULL OR FI_PedimentoComprobante.IdPedimentoComprobante IS NOT NULL)



--OBTENER INFORMACIÓN PRINCIPAL DE FACTURAS
INSERT INTO #TMP_Facturas(IdFactura,		IdSubcontratista,		MontoConIVAMXN,			UUID,
						FormaPago,			MetodoPago,				NumPagos,				UltimaPArcialidad,		
						FolioFiscalAsociado,IdMoneda,				Fecha,					MontoOriginal,
						Moneda)
SELECT 	FI_Factura.IdFactura,			FI_Factura.IdSubcontratista,		
		CASE WHEN PV_TipoMoneda.TipoMonedaCorto = 'USD' THEN FI_Factura.MontoConIva * CO_TipoCambioDiario.TipoCambio ELSE FI_Factura.MontoConIva END,				
		FI_Factura.UUID, NULL,	FI_Factura.MetodoPago,		COUNT(distinct FI_ComplementoDePago.IdFactura),	
		MAX([FI_CFDIRelacionados].NoParcialidad),			MAX(FC.UUID),	FI_Factura.IdMoneda,	FI_Factura.Fecha,	FI_Factura.MontoConIva,
		PV_TipoMoneda.TipoMonedaCorto
FROM #TMP_Gastos
INNER JOIN FI_Factura on FI_Factura.IdFactura = #TMP_Gastos.IdFactura
INNER JOIN PV_TipoMoneda ON PV_TipoMoneda.IdMoneda = FI_Factura.IdMoneda
LEFT JOIN [FI_CFDIMetodoPago] ON [FI_CFDIMetodoPago].IdCFDIMetodoPago = FI_Factura.ClaveFormaPago
LEFT JOIN  [dbo].[FI_CFDIRelacionados] ON  [dbo].[FI_CFDIRelacionados].UUID = FI_Factura.UUID 
LEFT JOIN FI_ComplementoDePago ON FI_ComplementoDePago.IdFactura = [FI_CFDIRelacionados].CFDIId
LEFT JOIN FI_factura FC	ON FC.IdFactura = [FI_CFDIRelacionados].CFDIId
LEFT JOIN CO_TipoCambioDiario ON CO_TipoCambioDiario.IdMoneda = 1 AND--MXN
								CO_TipoCambioDiario.Activo = 1 AND
								CONVERT(VARCHAR,CO_TipoCambioDiario.Fecha,112) = CONVERT(VARCHAR,FI_Factura.Fecha,112)
group by FI_Factura.IdFactura,			FI_Factura.IdSubcontratista,		FI_Factura.MontoConIva,
		FI_Factura.UUID,				[FI_CFDIMetodoPago].Concepto,		FI_Factura.MetodoPago,					
		CO_TipoCambioDiario.TipoCambio,	PV_TipoMoneda.TipoMonedaCorto,		FI_Factura.IdMoneda,		
		FI_Factura.Fecha			




--OBTENER INFORMACIÓN PRINCIPAL DE PEDIMENTOS
INSERT INTO #TMPPedimentos(IdPedimientoComprobante,ImporteTotalMXN,IdSubcontratista,FormaPago,Folio,IdMoneda,Fecha,ImporteTotalOrig,Moneda)
SELECT FI_PedimentoComprobante.IdPedimentoComprobante,SUM(FI_PedimentoComprobanteDetalle.ImporteTotal),
		CASE WHEN FI_PedimentoComprobante.CvTipoDocFacturacion = 3 THEN FI_PedimentoComprobante.IdSubcontratistaExportador
			 WHEN FI_PedimentoComprobante.CvTipoDocFacturacion = 2 THEN FI_PedimentoComprobante.IdSubcontratistaImportador
			 ELSE ISNULL(FI_PedimentoComprobante.IdSubcontratistaExportador,FI_PedimentoComprobante.IdSubcontratistaImportador)
		END,
		[FI_CFDIMetodoPago].Concepto,FI_PedimentoComprobante.FolioComprobante, FI_PedimentoComprobante.IdMoneda,FI_PedimentoComprobante.FechaPago,SUM(FI_PedimentoComprobanteDetalle.ImporteTotal),
		PV_TipoMoneda.TipoMonedaCorto
FROM FI_PedimentoComprobante 
INNER JOIN #TMP_Gastos ON #TMP_Gastos.IdPedimento = FI_PedimentoComprobante.IdPedimentoComprobante AND
										FI_PedimentoComprobante.CvTipoDocFacturacion IS NOT NULL
INNER JOIN FI_PedimentoComprobanteDetalle ON FI_PedimentoComprobanteDetalle.IdPedimentoComprobante = FI_PedimentoComprobante.IdPedimentoComprobante
INNER JOIN PV_TipoMoneda ON PV_TipoMoneda.IdMoneda = FI_PedimentoComprobante.IdMoneda
LEFT JOIN [FI_CFDIMetodoPago] ON [FI_CFDIMetodoPago].IdCFDIMetodoPago = FI_PedimentoComprobante.IdFormaPago
GROUP BY FI_PedimentoComprobante.IdPedimentoComprobante,		FI_PedimentoComprobante.IdSubcontratistaImportador,
		[FI_CFDIMetodoPago].Concepto,							FI_PedimentoComprobante.FolioComprobante,
		FI_PedimentoComprobante.IdSubcontratistaExportador,		FI_PedimentoComprobante.IdMoneda,	
		FI_PedimentoComprobante.FechaPago,						PV_TipoMoneda.TipoMonedaCorto,
		FI_PedimentoComprobante.CvTipoDocFacturacion



--OBTENER PAGOS POR COMPLEMENTOS CFDI
INSERT INTO #TMPTransferenciasFactura_Pagos(IdFactura,ImporteTotal,FechaPago,EsComplemento,IdMoneda,ImporteOriginal)
 SELECT  #TMP_Facturas.IdFactura, 
SUM(
			CASE WHEN PV_TipoMoneda.TipoMonedaCorto = 'USD' THEN FI_ComplementoDePago.Monto * CO_TipoCambioDiario.TipoCambio ELSE FI_ComplementoDePago.Monto END				
		)
,
MAX(FI_ComplementoDePago.FechaDePago),1,
Max(#TMP_Facturas.IdMoneda),
SUM(FI_ComplementoDePago.Monto)
 FROM dbo.FI_CPDocRelacionado
 INNER  JOIN dbo.FI_ComplementoDePago  ON FI_CPDocRelacionado.IdComplementoDePago = FI_ComplementoDePago.IdComplementoDePago
 INNER JOIN  #TMP_Facturas  ON FI_CPDocRelacionado.IdDocumento = #TMP_Facturas.UUID
 INNER JOIN PV_TipoMoneda ON PV_TipoMoneda.IdMoneda = #TMP_Facturas.IdMoneda
 LEFT JOIN CO_TipoCambioDiario ON CO_TipoCambioDiario.IdMoneda = 1 AND--MXN
								CO_TipoCambioDiario.Activo = 1 AND
								CONVERT(VARCHAR,CO_TipoCambioDiario.Fecha,112) = CONVERT(VARCHAR,#TMP_Facturas.Fecha,112)
GROUP BY #TMP_Facturas.IdFactura


-- OBTENER PAGOS POR TRANSFERENCIAS PARA FACTURAS
INSERT INTO #TMPTransferenciasFactura_Pagos(IdFactura,ImporteTotal,FechaPago,EsComplemento,IdMoneda,ImporteOriginal)
SELECT FI_Factura.IdFactura,
		SUM(
			CASE WHEN PV_TipoMoneda.TipoMonedaCorto = 'USD' THEN FI_Transfer.MontoPagado * CO_TipoCambioDiario.TipoCambio ELSE FI_Transfer.MontoPagado END				
		),
		MAX(FI_Transfer.FechaPago),				0,
		Max(#TMP_Facturas.IdMoneda),
		sum(FI_Transfer.MontoPagado)
FROM FI_Transfer 
INNER JOIN FI_TransferFactura ON FI_TransferFactura.IdTransfer = FI_Transfer.IdTransferencia
INNER JOIN FI_Factura ON FI_Factura.IdFactura = FI_TransferFactura.IdFactura
INNER JOIN #TMP_Facturas ON #TMP_Facturas.IdFactura = FI_Factura.IdFactura
INNER JOIN PV_TipoMoneda ON PV_TipoMoneda.IdMoneda = FI_Transfer.IdMoneda
LEFT JOIN CO_TipoCambioDiario ON CO_TipoCambioDiario.IdMoneda = 1 AND--MXN
								CO_TipoCambioDiario.Activo = 1 AND
								CONVERT(VARCHAR,CO_TipoCambioDiario.Fecha,112) = CONVERT(VARCHAR,FI_Transfer.FechaPago,112)
WHERE NOT EXISTS (SELECT 1 FROM #TMPTransferenciasFactura_Pagos ST1 WHERE ST1.IdFactura = FI_Factura.IdFactura) --SE PONE ESTA CONDICIÓN PARA NO TRAER PAGOS DUPLICADOS
GROUP BY FI_Factura.IdFactura


-- OBTENER PAGOS POR TRANSFERENCIAS PARA PEDIMENTOS
INSERT INTO #TMPTransferenciasFactura_Pagos(IdPedimento,ImporteTotal,FechaPago,EsComplemento,IdMoneda,ImporteOriginal)
SELECT FI_TransferFactura.IdPedimentoComprobante,
		SUM(
			CASE WHEN PV_TipoMoneda.TipoMonedaCorto = 'USD' THEN FI_Transfer.MontoPagado * CO_TipoCambioDiario.TipoCambio ELSE FI_Transfer.MontoPagado END				
		),
		MAX(FI_Transfer.FechaPago),				0,
		max(#TMPPedimentos.IdMoneda),
		SUM(FI_Transfer.MontoPagado)
FROM FI_Transfer 
INNER JOIN FI_TransferFactura ON FI_TransferFactura.IdTransfer = FI_Transfer.IdTransferencia
INNER JOIN FI_Factura ON FI_Factura.IdFactura = FI_TransferFactura.IdFactura
INNER JOIN #TMPPedimentos ON #TMPPedimentos.IdPedimientoComprobante = FI_TransferFactura.IdPedimentoComprobante
INNER JOIN PV_TipoMoneda ON PV_TipoMoneda.IdMoneda = FI_Transfer.IdMoneda
LEFT JOIN CO_TipoCambioDiario ON CO_TipoCambioDiario.IdMoneda = 1 AND--MXN
								CO_TipoCambioDiario.Activo = 1 AND
								CONVERT(VARCHAR,CO_TipoCambioDiario.Fecha,112) = CONVERT(VARCHAR,FI_Transfer.FechaPago,112)
GROUP BY FI_TransferFactura.IdPedimentoComprobante


		INSERT INTO #TRANSFERENCIA
         (IdTransfer, 
          UUID,
		  MetodoPago
         )
                SELECT FI_Transfer.IdTransferencia, 
                        SUBSTRING(LTRIM(RTRIM(ff.UUID)), 1, 500),
						PV_MetodoPago.MetodoPago
                FROM 
					dbo.FI_Transfer	(NOLOCK)
				LEFT JOIN 
					dbo.FI_TransferFactura TF	(NOLOCK)
					ON TF.IdTransfer = FI_Transfer.IdTransferencia
					AND	FI_Transfer.IdContrato = @pIdContrato
                LEFT JOIN 
					dbo.FI_Factura ff	(NOLOCK)
					ON tf.IdFactura = ff.IdFactura
				LEFT JOIN PV_MetodoPago ON PV_MetodoPago.idMetodoPago = FI_Transfer.IdMetodoPago
                WHERE 
					FI_Transfer.IdContrato = @pIdContrato
                    AND TF.IdTransfer IS NOT NULL
                GROUP BY 
					FI_Transfer.IdTransferencia, 
                    SUBSTRING(LTRIM(RTRIM(ff.UUID)), 1, 500),
					PV_MetodoPago.MetodoPago

		INSERT INTO #TRANSFERENCIA
         (IdTransfer, 
          UUID,
		  MetodoPago
         )
                SELECT FI_Transfer.IdTransferencia, 
                       SUBSTRING(LTRIM(RTRIM(fcr.IdDocumento)), 1, 500),
					   PV_MetodoPago.MetodoPago
                FROM 
					dbo.FI_Transfer (NOLOCK)
                LEFT JOIN 
					dbo.FI_TransferFactura TF	(NOLOCK)
					ON TF.IdTransfer = FI_Transfer.IdTransferencia
					AND	FI_Transfer.IdContrato = @pIdContrato
                LEFT JOIN 
					dbo.FI_Factura ff	(NOLOCK)
					ON tf.IdFactura = ff.IdFactura
                JOIN 
					dbo.FI_ComplementoDePago cp	(NOLOCK)
					ON cp.IdFactura = ff.IdFactura
                JOIN 
					dbo.FI_CPDocRelacionado fcr	(NOLOCK)
					ON fcr.IdComplementoDePago = cp.IdComplementoDePago
				LEFT JOIN PV_MetodoPago ON PV_MetodoPago.idMetodoPago = FI_Transfer.IdMetodoPago
                WHERE 
					FI_Transfer.IdContrato = @pIdContrato
                    AND TF.IdTransfer IS NOT NULL
                GROUP BY 
					FI_Transfer.IdTransferencia, 
                    SUBSTRING(LTRIM(RTRIM(fcr.IdDocumento)), 1, 500),
					PV_MetodoPago.MetodoPago

--RESULTADO FINAL
SELECT 
Anio = YEAR(CO_Registro.InicioEjecucion),
Mes = Month(CO_Registro.InicioEjecucion),
Subactividad = ISNULL(CO_SubactividadPetrolera.[id_Sub-actividad],'') +' '+ ISNULL(CO_SubactividadPetrolera.SubactividadPetrolera,''),
FolioFiscal = CASE WHEN LEN(ISNULL(#TMP_Facturas.UUID,''	)) > 0 THEN ISNULL(#TMP_Facturas.UUID,''	) ELSE ISNULL(#TMPPedimentos.Folio,'') END,
TareaGasto = ISNULL(CO_TareaPetrolera.id_Tarea,'') + ' '+ CO_TareaPetrolera.TareaPetrolera,
SubTarea = CO_Servicio.NombreServicio,
Concepto  = CO_Registro.Comentarios,
RFCEmisor = CASE WHEN #TMPPedimentos.IdSubcontratista IS NOT NULL THEN PV_Subcontratista_Pedimento.RazonSocial 
				ELSE ISNULL(PV_Subcontratista.RFC,PV_Subcontratista.RazonSocial) 
			END,
NaturalezaEmisor = 'Tercero',
ArchivoEPT= '',
ArchivoCFDI='',
ArchivoXML = '',
MontoTarea = CASE WHEN PV_TipoMoneda.TipoMonedaCorto = 'USD' THEN CO_Registro.MontoRegistro ELSE CO_Registro.MontoRegistro / CO_TipoCambioDiario.TipoCambio   END,
MontoTotalCFDI = CASE WHEN #TMP_Facturas.IdFactura IS NOT NULL THEN  #TMP_Facturas.MontoOriginal
					  WHEN  #TMPPedimentos.IdPedimientoComprobante IS NOT NULL THEN  isnull(#TMPPedimentos.ImporteTotalOrig,CO_Registro.MontoRegistro)
				END,
Moneda = CASE WHEN #TMP_Facturas.IdFactura IS NOT NULL THEN  #TMP_Facturas.Moneda
					  WHEN  #TMPPedimentos.IdPedimientoComprobante IS NOT NULL THEN 
									CASE WHEN ISNULL(#TMPPedimentos.ImporteTotalOrig,0) = 0 THEN PV_TipoMoneda.TipoMonedaCorto 
										ELSE #TMPPedimentos.Moneda 
									END
				END,
MontoTotalCFDIUSD = CASE WHEN #TMP_Facturas.IdFactura IS NOT NULL THEN  CASE WHEN #TMP_Facturas.Moneda = 'USD' THEN #TMP_Facturas.MontoOriginal ELSE #TMP_Facturas.MontoOriginal / TCFactura.TipoCambio  END
					  WHEN  #TMPPedimentos.IdPedimientoComprobante IS NOT NULL THEN   
								ISNULL(CASE WHEN #TMPPedimentos.Moneda = 'USD' THEN  #TMPPedimentos.ImporteTotalOrig 
									ELSE #TMPPedimentos.ImporteTotalOrig / TCPedimiento.TipoCambio  
								END,CO_Registro.MontoRegistro)
				END,
EstatusPago = CASE WHEN #TMPTransferenciasFactura_Pagos.importeOriginal >= #TMP_Facturas.MontoOriginal THEN 'PAGADA'
					WHEN #TMPTransferenciasFactura_Pagos.importeOriginal < #TMP_Facturas.MontoOriginal  AND #TMPTransferenciasFactura_Pagos.importeOriginal > 0 THEN 'PARCIALMENTE PAGADA'
				  WHEN #TMPTransferenciasFactura_Pagos.importeOriginal = 0 THEN 'PENDIENTE DE PAGO'
				  ELSE 'PENDIENTE DE PAGO'
			END,
FormaPagoID = CASE WHEN #TMPTransferenciasFactura_Pagos.importeOriginal >= #TMP_Facturas.MontoOriginal THEN ISNULL(#TRANSFERENCIA.MetodoPago, '')
					WHEN #TMPTransferenciasFactura_Pagos.importeOriginal < #TMP_Facturas.MontoOriginal  AND #TMPTransferenciasFactura_Pagos.importeOriginal > 0 THEN ISNULL(#TRANSFERENCIA.MetodoPago, '')
				  WHEN #TMPTransferenciasFactura_Pagos.importeOriginal = 0 THEN ''
				  ELSE ''
			END,
FechaPago = #TMPTransferenciasFactura_Pagos.FechaPago,
ComprobantePago = '',
ParcialidadesPagadas =  CASE WHEN #TMPTransferenciasFactura_Pagos.importeOriginal >= #TMP_Facturas.MontoOriginal THEN 1
							WHEN #TMPTransferenciasFactura_Pagos.importeOriginal < #TMP_Facturas.MontoOriginal  AND #TMPTransferenciasFactura_Pagos.importeOriginal > 0 THEN 1
							WHEN #TMPTransferenciasFactura_Pagos.importeOriginal = 0 THEN 0
							ELSE 0
						END,
ParcialidadesPendientes = CASE WHEN #TMPTransferenciasFactura_Pagos.importeOriginal >= #TMP_Facturas.MontoOriginal THEN 0
								WHEN #TMPTransferenciasFactura_Pagos.importeOriginal < #TMP_Facturas.MontoOriginal  AND #TMPTransferenciasFactura_Pagos.importeOriginal > 0 THEN 1
								WHEN #TMPTransferenciasFactura_Pagos.importeOriginal = 0 THEN 1
								ELSE 1
						END,
FolioFiscalAsociado = #TMP_Facturas.FolioFiscalAsociado,
Tipo = 'Elegible',
CuentaContable = [CO_CatalogoCuentaSH].Nivel3,
Descripcion = SH3.Descripcion

FROM CO_Registro
INNER JOIN #TMP_Gastos ON #TMP_Gastos.IdGasto = CO_Registro.IdRegistro
INNER JOIN CO_LineaPresupuestoMes ON CO_LineaPresupuestoMes.IdLineaPresupuestoMes = CO_Registro.IdPrograma

INNER JOIN CO_SubactividadPetrolera ON CO_SubactividadPetrolera.IdSubactividadPetrolera = CO_LineaPresupuestoMes.IdSubactividadPetrolera
INNER JOIN CO_TareaPetrolera ON CO_TareaPetrolera.IdTareaPetrolera = CO_LineaPresupuestoMes.IdTareaPetrolera
INNER JOIN CO_Servicio ON CO_Servicio.IdServicio = CO_LineaPresupuestoMes.IdServicio AND
							CO_Servicio.IdContrato = @pIdContrato
LEFT JOIN [dbo].[CO_CatalogoCuentaSH]  ON [CO_CatalogoCuentaSH].IdCatalogoCuentasSH = CO_Registro.IdCatalogoCuentasSH
LEFT JOIN [dbo].[CO_CatalogoCuentaSH] SH3  ON SH3.Nivel3 = [CO_CatalogoCuentaSH].Nivel3 AND
												SH3.IdVersion = 10002
LEFT JOIN #TMP_Facturas ON #TMP_Facturas.IdFactura = CO_Registro.IdFactura
LEFT JOIN #TMPPedimentos ON #TMPPedimentos.IdPedimientoComprobante = CO_Registro.IdPedimentoComprobante
left JOIN PV_TipoMoneda ON PV_TipoMoneda.IdMoneda = ISNULL(#TMP_Facturas.IdMoneda, #TMPPedimentos.IdMoneda)
LEFT JOIN PV_Subcontratista ON PV_Subcontratista.IdSubcontratista = #TMP_Facturas.IdSubcontratista
LEFT JOIN PV_Subcontratista PV_Subcontratista_Pedimento ON PV_Subcontratista_Pedimento.IdSubcontratista = #TMPPedimentos.IdSubcontratista
LEFT JOIN #TMPTransferenciasFactura_Pagos ON (
												#TMPTransferenciasFactura_Pagos.IdFactura = #TMP_Gastos.IdFactura OR
												#TMPTransferenciasFactura_Pagos.IdPedimento = #TMPPedimentos.IdPedimientoComprobante
											)
LEFT JOIN CO_TipoCambioDiario ON CO_TipoCambioDiario.IdMoneda = ISNULL(#TMP_Facturas.IdMoneda,#TMPPedimentos.IdMoneda) AND--MXN
								CO_TipoCambioDiario.Activo = 1 AND
								CONVERT(VARCHAR,CO_TipoCambioDiario.Fecha,112) = CONVERT(VARCHAR,CO_Registro.FecMovto,112)
LEFT JOIN CO_TipoCambioDiario TCFactura ON TCFactura.IdMoneda = #TMP_Facturas.IdMoneda AND--MXN
								TCFactura.Activo = 1 AND
								CONVERT(VARCHAR,TCFactura.Fecha,112) = CONVERT(VARCHAR,#TMP_Facturas.Fecha,112)
LEFT JOIN CO_TipoCambioDiario TCPedimiento ON TCPedimiento.IdMoneda = #TMPPedimentos.IdMoneda AND--MXN
								TCPedimiento.Activo = 1 AND
								CONVERT(VARCHAR,TCPedimiento.Fecha,112) = CONVERT(VARCHAR,#TMPPedimentos.Fecha,112)
LEFT JOIN #TRANSFERENCIA ON #TMP_Facturas.UUID = #TRANSFERENCIA.UUID 




	
IF OBJECT_ID('tempdb.dbo.#TMP_Gastos') IS NOT NULL DROP TABLE #TMP_Gastos
IF OBJECT_ID('tempdb.dbo.#TMPPedimentos') IS NOT NULL DROP TABLE #TMPPedimentos
IF OBJECT_ID('tempdb.dbo.#TMP_Facturas') IS NOT NULL DROP TABLE #TMP_Facturas
IF OBJECT_ID('tempdb.dbo.#TMPTransferenciasFactura_Pagos') IS NOT NULL DROP TABLE #TMPTransferenciasFactura_Pagos

