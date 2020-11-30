-- sp_IN_AL_ObtenerExistencias 1,0
Create Proc [dbo].[sp_IN_AL_ObtenerExistencias]
@pIdAlmacen int,
@pIdEstatus int -- 1. Libres, 2.Reserva , 0.Todos
as


	select 
		IdAlmacen,
		Almacen,
		IdMaterial,
		MaterialDes,
		MaterialDesLarga,
		Unidad,
		CantidadLibre,
		CantidadReserva,
		CantidadSolPed,
		CantidadPed,
		CantidadTra,
		CantidadEnAlmacen
	from vw_IN_AL_Existencias
	where IdAlmacen = @pIdAlmacen
	and (
		@pIdEstatus = 0 OR
		(
			@pIdEstatus = 1 and 
			(CantidadLibre > 0 OR CantidadSolPed > 0 OR CantidadPed > 0 OR CantidadTra > 0) 
		)
		OR
		(
			@pIdEstatus = 2 and 
			CantidadReserva > 0 
		)
	)
