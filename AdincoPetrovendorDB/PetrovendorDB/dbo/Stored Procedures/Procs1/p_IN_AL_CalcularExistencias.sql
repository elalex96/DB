-- p_IN_AL_CalcularExistencias 1,14952,9,1
create proc p_IN_AL_CalcularExistencias
@pIdAlmacen int,
@pIdMaterial int,
@pIdMovimientoDetalle int,
@pCreadoPor int

as

	declare @entradas decimal(15,3),
		@salidas decimal(15,3),
		@existencia decimal(15,3),
		@costoPromedio decimal(15,3),
		@costoUltimaCompra decimal(15,3)



	/******ENTRADAS************/
	select @entradas = isnull(sum(md.Cantidad),0)
	from IN_AL_Movimiento m
	inner join IN_AL_MovimientoDetalle md on md.idMovimiento = m.IdMovimiento and
									md.idMaterial = @pIdMaterial
	inner join IN_AL_TipoMovimiento tm on tm.IdTipoMovimiento = m.IdTipoMovimiento
	where m.IsEliminado = 0 and
	m.IdUsuarioAutorizo > 0 and
	m.IdAlmacen = @pIdAlmacen and
	tm.EsEntrada = 1

	/***************SALIDAS*************/
	select @salidas = isnull(sum(md.Cantidad),0)
	from IN_AL_Movimiento m
	inner join IN_AL_MovimientoDetalle md on md.idMovimiento = m.IdMovimiento and
									md.idMaterial = @pIdMaterial
	inner join IN_AL_TipoMovimiento tm on tm.IdTipoMovimiento = m.IdTipoMovimiento
	where m.IsEliminado = 0 and
	m.IdUsuarioAutorizo > 0 and
	m.IdAlmacen = @pIdAlmacen and
	tm.EsSalida = 1

	/**************COSTO PROMEDIO***********/
	select @costoPromedio =  SUM(md.PrecioTotal / (case when Cantidad = 0 then 1 else Cantidad end)) / count( distinct md.IdMovimientoDetalle)
								
	from IN_AL_Movimiento m
	inner join IN_AL_MovimientoDetalle md on md.idMovimiento = m.IdMovimiento and
									md.idMaterial = @pIdMaterial
	inner join IN_AL_TipoMovimiento tm on tm.IdTipoMovimiento = m.IdTipoMovimiento
	where isnull(m.IsEliminado,0) = 0 and
	--m.IdUsuarioAutorizo > 0 and
	m.IdAlmacen = @pIdAlmacen and
	tm.EsEntrada = 1

	/*********COSTO ULTIMA COMPRA***************/
	select  top 1 @costoUltimaCompra =  md.PrecioTotal / (case when Cantidad = 0 then 1 else Cantidad end)
	from IN_AL_Movimiento m
	inner join IN_AL_MovimientoDetalle md on md.idMovimiento = m.IdMovimiento and
									md.idMaterial = @pIdMaterial
	inner join IN_AL_TipoMovimiento tm on tm.IdTipoMovimiento = m.IdTipoMovimiento
	where isnull(m.IsEliminado,0) = 0 and
	--m.IdUsuarioAutorizo > 0 and
	m.IdAlmacen = @pIdAlmacen and
	tm.EsEntrada = 1
	order by IdMovimientoDetalle desc

	

	--select @entradas,@salidas,@costoPromedio,@costoUltimaCompra
	set @existencia = isnull(@entradas,0) - isnull(@salidas,0)

	if isnull(@pIdMovimientoDetalle,0) > 0
	begin 

		update IN_AL_MovimientoDetalle
		set Existencia = isnull(@existencia,0),
			CostoUltimaCompra = isnull(@costoUltimaCompra,0),
			CostoPromedio = isnull(@costoPromedio,0)
		where IdMovimientoDetalle = @pIdMovimientoDetalle

	end

	if exists (
		select 1
		from [dbo].[IN_AL_MaterialExistencias]
		where Almacenid = @pIdAlmacen and
		IdMaterial = @pidMaterial
	)
	begin 
		update [IN_AL_MaterialExistencias]
		set Existencia = isnull(@existencia,0),
		CostoUltimaCompra = isnull(@costoUltimaCompra,0),
		CostoPromedio = isnull(@costoPromedio,0),
		ModificadoEl = getdate()
		where Almacenid = @pIdAlmacen and
		IdMaterial = @pidMaterial
	end
	Else
	Begin
		insert into [IN_AL_MaterialExistencias](AlmacenId,IdMaterial,Existencia,CostoUltimaCompra,CostoPromedio,
		CreadoPor,CreadoEl,ModificadoPor,ModificadoEl)
		select @pIdAlmacen,@pIdMaterial,isnull(@existencia,0),isnull(@costoUltimaCompra,0),isnull(@costoPromedio,0),
		@pCreadoPor,getdate(),null,null
	End
	


