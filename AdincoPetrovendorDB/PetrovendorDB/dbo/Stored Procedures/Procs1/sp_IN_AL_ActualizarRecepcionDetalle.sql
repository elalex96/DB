
CREATE Proc [dbo].[sp_IN_AL_ActualizarRecepcionDetalle]
@pIdMovimientoDetalle int,
@pIdMovimiento int,
@pCantidad float,
@pModificadoPor int,
@pCustomError varchar(250) out
as


	declare @IdMaterial int,
			@IdPedidoDetalle int

	select @IdMaterial = pd.IdMaterial,
			@IdPedidoDetalle = md.IdPedidoDetalle
	from IN_AL_MovimientoDetalle md
	inner join MM_PedidoDetalle  pd on pd.IdPedidoDetalle = md.IdPedidoDetalle
	where md.IdMovimientoDetalle = @pIdMovimientoDetalle

	/*****************VALIDAR LA RECEPCIÓN****************************/
	select @pCustomError = dbo.fn_IN_AL_ValidarRecepcionDetalle(@pIdMovimientoDetalle,@IdPedidoDetalle,@IdMaterial,@pCantidad)

	
	if(@pCustomError <> '')
		return

	update IN_AL_MovimientoDetalle
	set Cantidad = @pCantidad,
		ModificadoPor = @pModificadoPor,
		ModificadoEl = getdate()
	where IdMovimientoDetalle = @pIdMovimientoDetalle
