
-- p_IN_AL_MovimientoExistencias 1,1
CREATE PROC p_IN_AL_MovimientoExistencias
@pIdMovimiento int,
@pIdUsuario int
as

		select m.idMovimiento,md.IdMovimientoDetalle,m.IdAlmacen,md.IdMaterial,m.CreadoPor
		into #tmpMovs
		from IN_AL_Movimiento m
		inner join IN_AL_MovimientoDetalle md on md.IdMovimiento = m.IdMovimiento
		where ISNULL(m.IsEliminado,0) = 0 and
		m.IdMovimiento = @pIdMovimiento and
		m.IdUsuarioAutorizo > 0

		declare  @pIdMovimientoDetalle int,
				@idAlmacen int,
				@idMaterial int,
				@creadoPor int

		select @pIdMovimientoDetalle = min(IdMovimientoDetalle)
		from #tmpMovs

		while @pIdMovimientoDetalle is not null
		begin
			
			select @idAlmacen =IdAlmacen,
				@idMaterial = IdMaterial,
				@creadoPor = CreadoPor
			from #tmpMovs
			where @pIdMovimientoDetalle = IdMovimientoDetalle


			select @idAlmacen,@idMaterial,@pIdMovimientoDetalle,@creadoPor
			exec p_IN_AL_CalcularExistencias @idAlmacen,@idMaterial,@pIdMovimientoDetalle,@creadoPor

			select @pIdMovimientoDetalle = min(IdMovimientoDetalle)
			from #tmpMovs
			where IdMovimientoDetalle > @pIdMovimientoDetalle

		end 
		

