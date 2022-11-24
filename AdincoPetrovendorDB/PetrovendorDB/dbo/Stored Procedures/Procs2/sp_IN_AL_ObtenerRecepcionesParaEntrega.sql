
-- sp_IN_AL_ObtenerRecepcionesParaEntrega 1,
create Proc [dbo].[sp_IN_AL_ObtenerRecepcionesParaEntrega]
	@pIdAlmacen int,
	@pIdMaterial int,
	@pCantidadEntrega float out /*En esta variable se regresará la cantidad que se pudo repartir entre los movimeintos de recepción, si se regresá un valor mayor a cero, indicará 
										que ya no habia cantidad disponible suficiente para surtir la entrega*/

AS
BEGIN

	declare @ueps int,
			@IdMovimientoDetalle int,
			@index int= 1,
			@cantidaEntregaAnt float
				

	create Table #tmpResult
	(
		i int identity(1,1),
		IdMovimientoDetalle int,
		FechaMovimiento datetime,
		Disponible float,
		Utilizado float null,
		utilizar bit
	)


	--Obtener UEPS o PEPS
	
	select @ueps = UEPS
	from IN_Almacen
	where IdAlmacen = @pIdAlmacen


	--Obtener el ultimo movimiento para el material
	if(@ueps =1 )
	begin

		
		insert into #tmpResult(IdMovimientoDetalle,FechaMovimiento,Disponible,utilizar)
		select   md.IdMovimientoDetalle,m.FechaMovimiento,isnull(md.Disponible,0),0
	
		from IN_AL_MovimientoDetalle md
		left join MM_PedidoDetalle pd on pd.IdPedidoDetalle = md.IdPedidoDetalle
		inner join IN_AL_Movimiento m on m.IdMovimiento = md.IdMovimiento
		where md.Disponible > 0 and
		md.IdMaterial = @pIdMaterial and
		m.IdTipoMovimiento IN( 1,4) --recepcion y reingreso sin ref
		and m.IsEliminado = 0
		order by m.FechaMovimiento desc

	end
	else
	begin
		
		insert into #tmpResult(IdMovimientoDetalle,FechaMovimiento,Disponible,utilizar)
		select 	   md.IdMovimientoDetalle,m.FechaMovimiento,isnull(md.Disponible,0)	,0	
		from IN_AL_MovimientoDetalle md
		left join MM_PedidoDetalle pd on pd.IdPedidoDetalle = md.IdPedidoDetalle
		inner join IN_AL_Movimiento m on m.IdMovimiento = md.IdMovimiento
		where md.Disponible > 0 and
		md.IdMaterial = @pIdMaterial and
		m.IdTipoMovimiento IN( 1,4) --recepcion y reingreso sin ref
		and m.IsEliminado = 0
		order by m.FechaMovimiento asc
	END


	--Si no se ecnontraron recepciones, buscar en los reingresos sin referencia
	IF NOT EXISTS (
		SELECT 1
		FROM #tmpResult
	)
	BEGIN
		insert into #tmpResult(IdMovimientoDetalle,FechaMovimiento,Disponible,utilizar)
		SELECT MD.IdMovimientoDetalle,m.FechaMovimiento,md.Disponible,0
		FROM dbo.IN_AL_Movimiento m
		INNER JOIN dbo.IN_AL_MovimientoDetalle md ON md.IdMovimiento = m.IdMovimiento
		WHERE m.IdTipoMovimiento = 4 and--Reing. sin ref
		md.IdMaterial = @pIdMaterial
    end

	---Recorrer	
	
	while @index <= (select count( distinct IdMovimientoDetalle) from #tmpResult)
		AND @pCantidadEntrega > 0
	begin

		set @cantidaEntregaAnt = @pCantidadEntrega

		select @pCantidadEntrega = isnull(@pCantidadEntrega,0) - isnull(Disponible,0)
		from #tmpResult
		where i=@index

		if @pCantidadEntrega <0
			set @pCantidadEntrega = 0

	
		
		update #tmpResult
		set utilizar = 1,
			Utilizado = @cantidaEntregaAnt - @pCantidadEntrega
		where i=@index

		set @index = @index +1

	end

	select IdMovimientoDetalle ,Utilizado
	from #tmpResult
	where utilizar = 1

	

END



