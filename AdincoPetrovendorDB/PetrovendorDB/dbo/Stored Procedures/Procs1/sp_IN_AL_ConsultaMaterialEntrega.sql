Create Proc [dbo].[sp_IN_AL_ConsultaMaterialEntrega]
As

	select *
	from IN_AL_Movimiento mov
	Inner join IN_AL_MovimientoDetalle movD on movD.IdMovimiento = mov.IdMovimiento
	inner join MM_PedidoDetalle pd on pd.IdPedidoDetalle = movD.IdPedidoDetalle
	inner join MM_Material mat on mat.IdMaterial = pd.IdMaterial
