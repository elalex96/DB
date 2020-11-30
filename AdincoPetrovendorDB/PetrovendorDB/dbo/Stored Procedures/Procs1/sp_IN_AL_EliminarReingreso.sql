
create Proc [dbo].[sp_IN_AL_EliminarReingreso]
@pIdAlmacen int,
@pIdMovimiento int,
@pModificadoPor int
as
Begin

	update IN_AL_Movimiento
	set IsEliminado = 1,
		ModificadoPor = @pModificadoPor,
		ModificadoEl = getdate()
	where IdAlmacen = @pIdAlmacen and
	IdMovimiento = @pIdMovimiento 

	End
