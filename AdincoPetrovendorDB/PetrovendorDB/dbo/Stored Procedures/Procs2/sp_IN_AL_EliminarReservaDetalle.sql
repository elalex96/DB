
Create Proc [dbo].[sp_IN_AL_EliminarReservaDetalle]
@pIdMovimiento int,
@pIdMovimientoDetalle int,
@pCustomError varchar(250) out
as

	if exists (
		select 1
		from IN_AL_Movimiento
		WHERE IdMovimiento = @pIdMovimiento and  IdUsuarioAutorizo > 0
	)
	begin

		set @pCustomError = 'No es posible eliminar un movimiento autorizado'
		return
		
	end
	
	


	delete IN_AL_MovimientoDetalle
	from IN_AL_MovimientoDetalle d
	inner join IN_AL_Movimiento m on m.IdMovimiento = d.IdMovimiento
	where d.IdMovimientoDetalle = @pIdMovimientoDetalle and
	IdUsuarioAutorizo is null --Eliminar solo si esta sin autorizar
