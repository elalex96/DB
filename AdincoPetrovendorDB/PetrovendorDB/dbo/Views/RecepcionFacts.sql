CREATE VIEW dbo.RecepcionFacts
AS
--EN NUEVO SCRIPT 
--EL MONTO MOSTRADO ES POR PARTIDA Y NO TIENE NINGUNA CONVERSIÓN DE MONEDA LA MONEDA SE OBTIENE DEL PEDIDO
--EL NUMERO DE PARTIDA MOSTRADO ES EL NUMERO DE LA REQUISICIÓN DETALLE
--LA DESCRIPCIÓN ES LA DEsCRIPCIÓN LARGA ES EL DE LA PARTIDA DEL PROVEEDOR VENDEDOR

SELECT 
	P.IdPedido as 'idunico pedido',
	S.IdSolicitudPedido as 'idunico de requisicion',
	C.NumeroContrato as 'contrato',
	PS.IdIdentificador as 'Numero de pedido',
	AP.IdAceptacionPedido as 'idAceptacionPedido',
	SPD.IdSolicitudPedidoDetalle as 'IdPartida',
	AP.NombreRecibidoPor as 'Recibido Por',
	POD.MaterialCotizadoTextoL as 'Descripcion',
	APD.Cantidad as 'Cantidad',
	CAST(PD.PrecioUnitario*APD.Cantidad as money) as 'Monto Aceptado',
	CAST(AP.Creado as date) as 'Fecha de recepcion'
FROM MM_AceptacionPedido  as AP (NOLOCK)
JOIN dbo.MM_Pedido P (NOLOCK)
	ON AP.IdPedido=P.IdPedido
JOIN MM_SolicitudPedido as S (NOLOCK)
	on P.IdSolicitudPedido = S.IdSolicitudPedido
JOIN MM_AceptacionPedidoDetalle as APD (NOLOCK)
	on  AP.IdAceptacionPedido = APD.IdAceptacionPedido
JOIN MM_PedidoDetalle as PD (NOLOCK)
	on P.IdPedido = PD.IdPedido 
	AND PD.IdPedidoDetalle=APD.IdPedidoDetalle
JOIN dbo.MM_PeticionOfertaDetalle POD (NOLOCK)
	ON POD.IdPeticionOfertaDetalle=PD.IdPeticionOfertaDetalle 
	AND POD.IdPeticionOferta=P.IdPeticionOferta
JOIN MM_SolicitudPedidoDetalle as SPD (NOLOCK)
	on S.IdSolicitudPedido = SPD.IdSolicitudPedido
	AND POD.IdSolicitudPedidoDetalle=SPD.IdSolicitudPedidoDetalle
JOIN adinco.dbo.CO_contrato as C (NOLOCK)
	on S.idcontrato = C.idcontrato
JOIN MM_Pedidos as PS 
	on P.IdPedido = PS.IdIdentificador 
	AND PS.IdProveedorCliente=P.IdProveedorCompras
WHERE
	P.IdProveedorCompras in (606, 676, 690, 1315, 1424) 
	AND ISNULL(AP.IdEstatusEliminado, 0) <> 1 --> MOSTRAR ACEPTACIONES NO ELIMINADAS    
GROUP BY
	P.IdPedido,
	S.IdSolicitudPedido,
	C.NumeroContrato,
	PS.IdIdentificador,
	AP.IdAceptacionPedido,
	SPD.IdSolicitudPedidoDetalle,
	AP.NombreRecibidoPor,
	PD.Cantidad,
	POD.MaterialCotizadoTextoL,
	PD.PrecioUnitario,
	APD.Cantidad,
	AP.Creado

--NOTAS RECEPCIONES 
--SE NECESITA UN MONTO TOTAL CON TIPO DE MONEDA ESPECIFICO?
--SE CORRIGIO NUMERO DE PARTIDA, DESCRIPCION, MONTO ACEPTADO, CANTIDAD, FECHA DE RECEPCION, NUMERO DE PEDIDO 

