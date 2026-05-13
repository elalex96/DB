
create Proc [dbo].[sp_IN_AL_ActualizarReservaDetalle]
@pIdAlmacen int,
@pIdMovimientoDetalle	int,
@pIdMovimiento	int,
@pCantidad	decimal(14,2),
@pModificadoPor	int,
@pIdMaterial int,
@pCustomError varchar(250) out
as

	declare @NoItem int


	select @pCustomError = dbo.fn_IN_AL_ValidarReserva(@pIdAlmacen,@pIdMovimiento,@pIdMovimientoDetalle,@pIdMaterial,@pCantidad)

	if @pCustomError <> ''
		return


	update IN_AL_MovimientoDetalle
	set Cantidad = @pCantidad,
		IdMaterial = @pIdMaterial,
		ModificadoPor = @pModificadoPor,
		ModificadoEl = getdate()
	where IdMovimiento = @pIdMovimiento and
	IdMovimientoDetalle=@pIdMovimientoDetalle
