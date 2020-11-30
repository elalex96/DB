-- sp_IN_AL_ObtenerReservaMsgAut 10
Create Proc [dbo].[sp_IN_AL_ObtenerReservaMsgAut]
@pIdMovimientoReserva int
as
begin




	select FolioReserva = mov.Folio,
			Material =  isnull(mov.MaterialDes,''),
		   CantidadASolicitar = abs(mov.DisponibleTotalAlmacen - mov.Cantidad)
	from [dbo].[vw_IN_AL_Movimientos] mov
	where mov.IdMovimiento = @pIdMovimientoReserva and
	mov.DisponibleTotalAlmacen - mov.Cantidad <= 0
	


	

end


