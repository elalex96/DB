
CREATE Proc [dbo].[sp_IN_AL_InsertarReservaDetalle]
@pIdAlmacen int,
@pIdMovimientoDetalle	int,
@pIdMovimiento	int,
@pCantidad	decimal(14,2),
@pCreadoPor	int,
@pIdMaterial int,
@pCustomError varchar(250) out
as

	declare @NoItem int


	select @pCustomError = dbo.fn_IN_AL_ValidarReserva(@pIdAlmacen,@pIdMovimiento,@pIdMovimientoDetalle,@pIdMaterial,@pCantidad)

	if @pCustomError <> ''
		return


	select @pIdMovimientoDetalle  =isnull(max(IdMovimientoDetalle),0) + 1
	from IN_AL_MovimientoDetalle

	select @NoItem  =isnull(max(NoItem),0) + 1
	from IN_AL_MovimientoDetalle
	where IdMovimiento = @pIdMovimiento
	
	insert into IN_AL_MovimientoDetalle(
		IdMovimientoDetalle,		IdMovimiento,		IdPedidoDetalle,		NoItem,
		Cantidad,					Disponible,			CreadoPor,				CreadoEl,
		ModificadoPor,				ModificadoEl,		PrecioTotal,			IdMaterial
	)
	values(
		@pIdMovimientoDetalle,		@pIdMovimiento,		null,					@NoItem,
		@pCantidad,					0,					@pCreadoPor,			getdate(),
		null,						null,				0,						@pIdMaterial				
	)

