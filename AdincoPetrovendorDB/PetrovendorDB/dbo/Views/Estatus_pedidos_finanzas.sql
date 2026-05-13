
CREATE VIEW Estatus_pedidos_finanzas
AS
	
    SELECT
        epj.Contrato,
        epj.OrdenCompra AS [Pedido/OrdenCompra], 
        epj.SolicitudPedido,
        epj.CreadoEl,
        epj.DiasPedido  AS [Dias del Pedido], 
        epj.Proveedor,
        epj.CorreoProveedor,
        epj.RFC,
        epj.Estado,
        epj.Version,
        epj.Moneda,																	/*Moneda*/
        epj.TipoPedido,
        epj.Aprobadores,
        epj.EstatusAprobador,
        epj.EstatusFactura,
        epj.EstatusPago,															/*Estatus*/
        epj.Factura,
        epj.EstatusRecepcionServicio AS ConfirmacionPedidoProveedor,
        epj.EstatusCN,
        epj.Entidad_Jaguar,
        epj.CuentaOrigen,															/*Cuenta Cargo*/
        epj.CuentaDestino,															/*Cuenta Abono*/
        epj.FechaRegistroTranferencia,
        epj.MontoTransfer,															/*Importe*/
        epj.MonedaTransfer,															/*Moneda*/
        epj.MontoTotalOrdenCompra,
        epj.Instalacion,
        epj.Motivo,																	/*Concepto*/
        CASE WHEN epj.PedidoCancelado = 0 THEN 'NO' ELSE 'SI' END AS PedidoCancelado,
        epj.MontoAceptacion,
        epj.DiasCredito,
        epj.FechaPagoSegunDiasCredito,
        epj.FechaIngreso    AS FechaRecepcionServicio,
        epj.UUIDFactura AS UUID_Procura,
        epj.UUID_Adinco,
        epj.UUIDComplemento,
        epj.UltimaFechaAprobaciones,
        epj.FechaTransferencia,
        epj.FechaCotizacion,
        epj.FechaAprobacionOC,
        epj.FechaAprobacionCartaCN,
        epj.FechaAprobacionFactura,
        epj.FechaFactura,
        epj.MontoPagadoFactura,
		-------------------------------------------------------
		Estatus				=		epj.EstatusPago,
		TipoPago			=		(case when dbo.getBancoID(epj.CuentaDestino) = dbo.getBancoID(epj.CuentaOrigen) then 'MISMO BANCO' else 'CLABE INTERBANCARIA'
											end),
		CuentaAbono			=		epj.CuentaDestino,
		CuentaCargo			=		epj.CuentaOrigen,
		MonedaPago			=		epj.Moneda,
		Importe				=		epj.MontoTransfer,
		Beneficiario		=		dbo.getTitularCuenta(epj.CuentaDestino),
		Concepto			=		epj.Motivo
		
    FROM
        EstatusPedidosJaguar		epj(NOLOCK)
	WHERE
        IdProveedorCompras IN   (606, 690, 1835)
		
	UNION
	
	SELECT
		NumeroContrato AS Contrato,
		Pedido AS [Pedido/OrdenCompra],
		'',
		CreadoEl,
		DiasPedido AS [Dias del Pedido],
		Proveedor,
		'',
		RFCProveedor AS [RFC],
		Estado,
		'',
		Moneda,
		'Compra Directa' AS [TipoPedido],
		Aprobadores,
		EstatusFactura AS [EstatusAprobador],
		EstatusFactura,
		EstatusPago,
		LTRIM(RTRIM(CONCAT(ISNULL(CD.Serie,''),' ',ISNULL(CD.Folio,'')))) AS [Factura],
		'',
		EstatusCN,
		RSContratista AS [Entidad_Jaguar],
		CuentaOrigen,
		CuentaDestino,
		FechaRegistroTransferencia,
		MontoTransfer,
		MonedaTransfer,
		MontoRegistro AS [MontoTotalOrdenCompra],
		Instalacion,
		Motivo,
		'',
		'',
		'',
		'',
		'',
		UUID_Petrovendor AS [UUID_Procura],
		UUID_Adinco,
		UUID_C AS [UUIDComplemento],
		FechaAprobacionFactura AS [UltimaFechaAprobaciones],
		FechaTransferencia,
		'',
		FechaAprobacionFactura AS [FechaAprobacionOC],
		FechaAprobacionFactura AS [FechaAprobacionCartaCN],
		FechaAprobacionFactura,
		FechaFactura,
		MontoTransferFactura AS [MontoPagadoFactura],
		---------------------------------------------------
		Estatus					=	EstatusPago,
		TipoPago				=		(case when dbo.getBancoID(CuentaDestino) = dbo.getBancoID(CuentaOrigen) then 'MISMO BANCO'	else 'CLABE INTERBANCARIA'
											end),
		CuentaAbono				=	CuentaDestino,
		CuentaCargo				=	CuentaOrigen,
		MonedaPago				=	Moneda,
		Importe					=	MontoTransfer,
		Beneficiario		=		dbo.getTitularCuenta(CuentaDestino),
		Concepto				=	Motivo
	FROM
		VISTA_ComprasDirectas CD

UNION

SELECT
	CO.NumeroContrato	COLLATE Modern_Spanish_CI_AS,
	NULL			AS [Pedido/OrdenCompra],
	NULL			AS	SolicitudPedido,
	PC.CreadoEn		AS CreadoEl,
	NULL			AS [Dias del Pedido],
	P.RazonSocial	COLLATE Modern_Spanish_CI_AS AS	Proveedor,
	P.CorreoProveedor	COLLATE Modern_Spanish_CI_AS AS	CorreoProveedor,
	ISNULL(P.RFC,'')	COLLATE Modern_Spanish_CI_AS AS	[RFC],
	ET.Nombre		COLLATE Modern_Spanish_CI_AS AS	Estado,
	''				AS Version,
	TM.TipoMonedaCorto	COLLATE Modern_Spanish_CI_AS AS	Moneda,
	'Comprobante'	AS [TipoPedido],
	dbo.fnGetAprobadores(OP.IdOperacion) COLLATE Modern_Spanish_CI_AS as Aprobadores,
	''				AS	EstatusAprobador,
	ET.Nombre		COLLATE Modern_Spanish_CI_AS	AS	EstatusFactura,
	EstatusPago = case when tra.IdTransferFactura is null then 'NO PAGADO' else 'PAGADO' end,
	'#: ' + LTRIM(RTRIM(CONCAT(ISNULL(PC.NumeroPedimento,''),' - Clave: ',ISNULL(PC.ClavePedimento,'')))) COLLATE Modern_Spanish_CI_AS  AS [Factura],
	''				AS	ConfirmacionPedidoProveedor,
	''				AS	EstatusCN,
	P.RazonSocial	COLLATE Modern_Spanish_CI_AS AS	Entidad_Jaguar,
	''		AS	CuentaOrigen,
    ''		AS	CuentaDestino,
    NULL		AS	FechaRegistroTranferencia,
	tr.MontoPagado		AS	MontoTransfer,
	tmtr.TipoMonedaCorto	AS	MonedaTransfer,
	PCD.ImporteTotal	AS	MontoTotalOrdenCompra,
	NULL	AS	Instalacion,
	ISNULL(PCD.DescripcionMercancia,'')	COLLATE Modern_Spanish_CI_AS AS	Motivo,
	NULL	AS PedidoCancelado,
	NULL	AS MontoAceptacion,
	NULL	AS DiasCredito,
	NULL	AS FechaPagoSegunDiasCredito,
	NULL	AS FechaRecepcionServicio,
	NULL	AS UUID_Procura,
	NULL	AS UUID_Adinco,
	NULL	AS UUIDComplemento,
	dbo.FN_FechaAprobacionPedido (OP.IdOperacion)	AS	UltimaFechaAprobaciones,
	NULL	AS FechaTransferencia,
	NULL	AS FechaCotizacion,
	NULL	AS FechaAprobacionOC,
	NULL	AS FechaAprobacionCartaCN,
	NULL	AS FechaAprobacionFactura,
    PC.FechaPago	AS    FechaFactura,
	NULL	AS	MontoPagadoFactura,
	-------------------------------------------------------------------------------
	Estatus = case when tra.IdTransferFactura is null then 'NO PAGADO' else 'PAGADO' end,
	TipoPago	=	'',--	(case when dbo.getBancoID(CuentaDestino) = dbo.getBancoID(CuentaOrigen) then 'MISMO BANCO'	else 'CLABE INTERBANCARIA' end),
	CuentaAbono =	'',
	CuentaCargo	=	'',
	MonedaPago	=	TM.TipoMonedaCorto	COLLATE Modern_Spanish_CI_AS,
	Importe		=	tr.MontoPagado,
	Beneficiario =	'',
	Concepto	=	ISNULL(PCD.DescripcionMercancia,'')	COLLATE Modern_Spanish_CI_AS
FROM	dbo.FI_AceptacionPedido_PedimentoComprobante	APC	(NOLOCK)
JOIN	dbo.TA_Operacion								OP	(NOLOCK)
ON		APC.IdAceptacionPedidoPedimentoComprobante		=	OP.IdDocumento
AND		OP.IdTipoOperacion								=	19
AND		OP.IdProveedor									=	APC.IdProveedor
AND		APC.IdProveedor									=	420 --in (606, 690, 1835)
AND		APC.Activo										=	1
/**/JOIN	dbo.FI_PedimentoComprobante						PC	(NOLOCK) --select * from sys.tables where name like '%adinco%'   
left join	FI_RelacionComprobanteAdinco				rca
on			rca.IdComprobantePetrovendor				=	PC.IdPedimentoComprobante
left join	Adinco..FI_TransferFactura						tra
on			tra.CvTipoDocFacturacion					=	3
and			tra.IdPedimentoComprobante					=	rca.IdComprobanteAdinco
left join	Adinco..FI_Transfer							tr
on			tr.IdTransferencia							=	tra.IdTransfer
left join	PV_TipoMoneda								tmtr
on			tmtr.IdMoneda								=	tr.IdMoneda
ON		APC.IdPedimentoComprobante						=	PC.IdPedimentoComprobante
JOIN	FI_PedimentoComprobanteDetalle					PCD	(NOLOCK)
ON		PCD.IdPedimentoComprobante						=	PC.IdPedimentoComprobante
JOIN	dbo.S_Usuario									US	(NOLOCK)
ON		US.IdUsuario									=	APC.CreadoPor
JOIN	Adinco.dbo.CO_Contrato							CO	(NOLOCK)
ON		PC.IdContrato									=	CO.IdContrato
JOIN	Adinco.dbo.PV_TipoMoneda						TM	(NOLOCK)
ON		TM.IdMoneda										=	PC.IdMoneda
JOIN	dbo.TA_Estatus									ET	(NOLOCK)
ON		OP.IdEstatusOperacion							=	ET.IdEstatus
JOIN	S_Proveedor										P	(NOLOCK)
ON		APC.IdProveedor									=	P.IdProveedor
WHERE	APC.IdProveedor									=	420 --in (606, 690, 1835)
AND		APC.Activo										=	1


