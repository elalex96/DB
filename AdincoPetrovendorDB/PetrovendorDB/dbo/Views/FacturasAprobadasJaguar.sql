CREATE VIEW [dbo].[FacturasAprobadasJaguar]
AS

-------------------------------------------------------------------
---------------------- FACTURAS APROBADAS -------------------------
-------------------------------------------------------------------
SELECT  U.Nombre as Solicitante,
		Aprobadores,
		FechaAprobacionFactura, 
		EPJ.Contrato, 
		Proveedor, 
		ISNULL(F.Serie COLLATE Modern_Spanish_CI_AS, '') AS Serie,  
		ISNULL(F.Folio COLLATE Modern_Spanish_CI_AS, '') AS Folio,  
		EPJ.UUID_Adinco , 
		LTRIM(F.Moneda COLLATE Modern_Spanish_CI_AS) AS Moneda, 
		EPJ.TotalFactura, 
		EPJ.ConceptoFactura, 
		EPJ.SubTotalFactura, 
		F.FechaTimbrado,
		CASE
			WHEN SP.IdTipoGasto = 1
			THEN 'CAPEX'
			WHEN SP.IdTipoGasto = 2
			THEN 'OPEX'
		END AS TipoGasto,
		ISNULL(F.MetodoPago, '') AS MetodoPago,
		F.Emisor COLLATE Modern_Spanish_CI_AS as RFC,
		ISNULL(F.TotalImpuestosTrasladados,0) AS TotalImpuestosTrasladados,
		ISNULL(F.TotalImpuestosRetenidos,0) AS TotalImpuestosRetenidos
FROM  EstatusPedidosJaguar EPJ WITH (NOLOCK)
JOIN  Adinco.dbo. FI_Factura F WITH (NOLOCK) ON F.UUID COLLATE SQL_Latin1_General_CP1_CI_AS = EPJ.UUID_Adinco --collate Modern_Spanish_CI_AS
join MM_SolicitudPedido SP (NOLOCK) on EPJ.SolicitudPedido = SP.IdSolicitudPedido
join S_Usuario U (NOLOCK) on SP.IdUsuarioSolicitante = U.IdUsuario
WHERE        (IdProveedorCompras IN (606, 690, 1835))   AND FechaAprobacionFactura IS NOT NULL
-------------------------------------------------------------------
-- UNION PARA INCORPORAR LA COMPRA DIRECTA ------------------------
-------------------------------------------------------------------
UNION
SELECT distinct stuff ((select ', ' + US.Nombre from S_Usuario US
								join TA_Operacion (NOLOCK) O on US.IdUsuario = O.IdAsignador
								where O.IdOperacion = CDF.IdOperacion
								for XML PATH ('')), 1, 2, '') Solicitante,
	   stuff ((select ', ' + U.Nombre from S_Usuario U
						join TA_Tarea T (NOLOCK) on T.IdAprobador = U.IdUsuario
						where T.IdOperacion = CDF.IdOperacion
						for XML PATH ('')), 1, 2, '') Aprobador,
	   CDF.FechaAprobacionFactura, 
       CDF.NumeroContrato, 
       CDF.Proveedor, 
       cdf.serie, 
       cdf.folio, 
       CDF.UUID_Adinco, 
       CDF.Moneda, 
       CDF.TotalFactura, 
       CDF.ConceptoFactura, 
       CDF.SubTotalFactura, 
	   ff.FechaTimbrado,
	   '',
	   ISNULL(ff.MetodoPago, '') COLLATE Modern_Spanish_CI_AS AS MetodoPago,
	   ff.Emisor as RFC,
	   isnull(FA.TotalImpuestosTrasladados,0) AS TotalImpuestosTrasladados,
	   isnull(FA.TotalImpuestosRetenidos,0) AS TotalImpuestosRetenidos
FROM VISTA_ComprasDirectas CDF WITH (NOLOCK)
join TA_Tarea T  (NOLOCK) on CDF.IdOperacion = T.IdOperacion
	AND CDF.Receptor IN('JEP1709042B1', 'PEP170906DI5', 'JSE1601292U8') 
join TA_Operacion O (NOLOCK) on T.IdOperacion = O.IdOperacion
	and O.IdTipoOperacion = 14
join S_Usuario U (NOLOCK) ON U.IdUsuario = T.IdAprobador 
join MM_Pedidos PP (NOLOCK) on O.IdDocumento = PP.IdIdentificador
	 AND PP.IdProveedorCliente in (606, 690, 1835)
join S_Usuario US (NOLOCK) on PP.IdCreadoPor = US.IdUsuario
JOIN dbo.FI_Factura ff (NOLOCK) ON cdf.UUID_Petrovendor = ff.UUID
join Adinco.dbo.FI_FacturaAdincoPetrovendor AS FAP (NOLOCK)
	on   ff.IdFactura =  FAP.IdFacturaPetrovendor
    AND FAP.Activo    =    1
join Adinco.dbo.FI_Factura AS FA (NOLOCK)
    ON FAP.IdFacturaAdinco = FA.IdFactura
WHERE 
CDF.Receptor IN('JEP1709042B1', 'PEP170906DI5', 'JSE1601292U8') 
and O.IdTipoOperacion = 14 and PP.IdProveedorCliente in (606, 690, 1835)
GROUP BY US.Nombre,
		 U.Nombre,
		 CDF.IdOperacion,
		 CDF.FechaAprobacionFactura, 
         CDF.NumeroContrato, 
         CDF.Proveedor, 
         cdf.serie, 
         cdf.folio, 
         CDF.UUID_Adinco, 
         CDF.Moneda, 
         CDF.TotalFactura, 
         CDF.ConceptoFactura, 
         CDF.SubTotalFactura,
		 ff.FechaTimbrado,
		 ff.MetodoPago,
		 ff.Emisor,
		 FA.TotalImpuestosTrasladados,
		 FA.TotalImpuestosRetenidos
-------------------------------------------------------------------
-- UNION PARA INCORPORAR LOS PEDIMENTOS COMPROBANTES APROBADOS ----
-------------------------------------------------------------------
 UNION
SELECT
			US.Nombre AS Solicitante,
			dbo.fnGetAprobadores(OP.IdOperacion) COLLATE Modern_Spanish_CI_AS as Aprobadores,
			dbo.FN_FechaAprobacionPedido (OP.IdOperacion) as FechaAprobacionFactura,
			CO.NumeroContrato COLLATE Modern_Spanish_CI_AS,
			P.RazonSocial,
			ISNULL(PC.NumeroPedimento COLLATE Modern_Spanish_CI_AS, '') AS Serie,  
			LTRIM(ISNULL(PC.ClavePedimento, '')) COLLATE Modern_Spanish_CI_AS AS Folio,
			''	AS UUID,	-- NO EXISTE UUID EN LOS PEDIMENTOS
			TM.TipoMonedaCorto,
			PCD.ImporteTotal	As	TotalFactura,
			ISNULL(PCD.DescripcionMercancia,'')	COLLATE Modern_Spanish_CI_AS	AS	ConceptoFactura,
			PCD.PrecioUnitario	AS	SubTotalFactura,
			PC.FechaPago		AS	FechaTimbrado,
			''	AS TipoGasto,
			ISNULL(FP.Descripcion, '') as MetodoPago,
			ps.RFC as RFC,
			0 AS TotalImpuestosTrasladados,
			0 AS TotalImpuestosRetenidos
	FROM dbo.FI_AceptacionPedido_PedimentoComprobante AS APC	(NOLOCK)
		JOIN dbo.TA_Operacion AS OP	(NOLOCK)
			ON	APC.IdAceptacionPedidoPedimentoComprobante = OP.IdDocumento
			AND OP.IdTipoOperacion = 19
			AND OP.IdProveedor = APC.IdProveedor
			AND APC.IdProveedor in (606, 690, 1835)
			AND APC.Activo = 1
		JOIN dbo.FI_PedimentoComprobante AS PC	(NOLOCK)
			ON APC.IdPedimentoComprobante	=	PC.IdPedimentoComprobante
		JOIN
			FI_PedimentoComprobanteDetalle	PCD	(NOLOCK)
			ON	PCD.IdPedimentoComprobante	=	PC.IdPedimentoComprobante
		JOIN dbo.S_Usuario AS US	(NOLOCK)
			ON US.IdUsuario = APC.CreadoPor
		JOIN Adinco.dbo.CO_Contrato	CO	(NOLOCK)
			ON	PC.IdContrato	=	CO.IdContrato
		JOIN Adinco.dbo.PV_TipoMoneda AS TM	(NOLOCK)
			ON TM.IdMoneda = PC.IdMoneda
		JOIN dbo.TA_Estatus AS ET	(NOLOCK)
			ON OP.IdEstatusOperacion = ET.IdEstatus
			AND	ET.IdEstatus	=	2
		JOIN	
			S_Proveedor	P	(NOLOCK)
			ON	APC.IdProveedor	=	P.IdProveedor
		left join Adinco.dbo.catCFDI_c_FormaPago AS FP 	(NOLOCK)
			ON ISNULL(PC.IdFormaPago, 1) = FP.IdFormaPago
		left join Adinco.dbo.PV_Subcontratista as PS 	(NOLOCK)
			ON PC.IdSubcontratistaExportador = PS.idSubcontratista
	WHERE APC.IdProveedor in (606, 690, 1835)
		AND APC.Activo = 1