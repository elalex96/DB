CREATE VIEW [dbo].[EstatusPedidosGral]
AS

SELECT DISTINCT
	P.Contrato,
	P.OrdenCompra	AS IdPedido,
	P.SolicitudPedido,
	P.CreadoEl,
	P.DiasPedido,
	P.Proveedor,
	P.Estado,
	P.Version,
	P.Moneda,
	P.TipoPedido,
	P.Aprobadores,
	P.EstatusAprobador,
	P.EstatusFactura,
	P.EstatusPago,
	P.Factura,
	P.EstatusRecepcionServicio AS RecepcionServicio,
	P.EstatusCN,
	P.FechaRegistroTranferencia AS FechaRegistroTransferencia,
	P.MontoTransfer,
	P.MonedaTransfer,
	P.MontoTotalOrdenCompra,
	P.Instalacion AS [Instalación],
	P.Motivo,
	CASE WHEN ISNULL(P.PedidoCancelado, 0) = 0
        THEN 'NO'
        ELSE 'SI'
    END AS [PedidoCancelado],
	P.MontoAceptacion,
	P.DiasCredito,
	P.FechaPagoSegunDiasCredito,
	ISNULL(AC.NombreAreaContractual, '') AS AreaContractual,
	DATEDIFF(DAY, P.CreadoEl, ISNULL(P.FechaTransferencia,GETDATE())) AS [Dias Totales Pedido],
	P.FechaIngreso AS [FecRecepcionServ]
FROM
	EstatusPedidosJaguar	P	(NOLOCK)
JOIN
	Adinco.dbo.CO_Contrato	C	(NOLOCK)
	ON	P.IdContrato	=	C.IdContrato
JOIN
	Adinco.dbo.CO_AreaContractual AC	(NOLOCK)
	ON	C.IdAreaContractual = AC.IdAreaContractual
WHERE
	P.IdProveedorCompras IN	(606, 690, 1835)