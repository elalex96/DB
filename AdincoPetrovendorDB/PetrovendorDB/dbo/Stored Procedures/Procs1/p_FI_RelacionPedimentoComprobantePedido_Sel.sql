create proc p_FI_RelacionPedimentoComprobantePedido_Sel
@pIdRelacionPedimentoComprobante int
as


	select t1.IdRelacionPedimentoComprobante,
			t1.IdPedido,
			t1.NombreDoc,
			t1.Carpeta,
			t1.Identificador,
			t1.Extension,
			t1.Mime,
			t1.Activo,
			t1.CreadoPor,
			t1.CreadoEl,
			t1.IdPedimentoComprobanteADINCO,
			t1.IdProveedorVenta,
			Reportado = cast(isnull(pedAdinco.Reportado,0) as bit),
			Folio = t2.FolioComprobante
	from MPY_FI_RelacionPedimentoComprobantePedido t1
	inner join Adinco..FI_PedimentoComprobante pedAdinco on pedAdinco.IdPedimentoComprobante =  t1.IdPedimentoComprobanteADINCO
	inner join FI_PedimentoComprobante t2 on  t2.IdPedimentoComprobante = pedAdinco.IdPedimentoComprobantePetrovendor
	where IdRelacionPedimentoComprobante = @pIdRelacionPedimentoComprobante