
create Proc [dbo].[sp_IN_AL_InsertarRecepcionDetalle]
@pIdMovimientoDetalle	int,
@pIdMovimiento	int,
@pIdPedidoDetalle	int,
@pNoItem	int,
@pCantidad	decimal(14,2),
@pDisponible	decimal(14,2),
@pCreadoPor	int,
@pCustomError varchar(250) out
as

	declare @IdMaterial int,
		@precioUnitario money,
		@PrecioTotal money

	select @IdMaterial = IdMaterial,
			@precioUnitario = PrecioUnitario,
			@PrecioTotal = PrecioUnitario * @pCantidad
	from MM_PedidoDetalle 
	where IdPedidoDetalle = @pIdPedidoDetalle


	/*****************VALIDAR LA RECEPCIÓN****************************/
	select @pCustomError = dbo.fn_IN_AL_ValidarRecepcionDetalle(@pIdMovimientoDetalle,@pIdPedidoDetalle,@IdMaterial,@pCantidad)


	if(@pCustomError <> '')
		return


	select @pIdMovimientoDetalle = isnull(max(IdMovimientoDetalle),0) + 1
	from IN_AL_MovimientoDetalle

	select @pNoItem = isnull(max(NoItem),0) + 1
	from IN_AL_MovimientoDetalle
	where IdMovimiento = @pIdMovimiento

	insert into IN_AL_MovimientoDetalle(
		IdMovimientoDetalle,		IdMovimiento,		IdPedidoDetalle,		NoItem,			Cantidad,
		Disponible,					CreadoPor,			CreadoEl,				ModificadoPor,	ModificadoEl,
		PrecioTotal,				IdMaterial				)
	values(
		@pIdMovimientoDetalle,		@pIdMovimiento,		@pIdPedidoDetalle,		@pNoItem,		@pCantidad,
		0,							@pCreadoPor,		GETDATE(),				null,			null,
		@PrecioTotal,							@IdMaterial						
		
	)
