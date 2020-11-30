

CREATE FUNCTION dbo.fn_IN_AL_ValidarRecepcionDetalle
(
	@pIdMovimientoDetalle int,
	@pIdPedidoDetalle int,
	@pIdMaterial int,
	@pIdCantidad float
)
RETURNS varchar(250)
AS
BEGIN

	declare @result varchar(250)='',
			@porcTolerancia float,
			@cantidadTotalRecepcion float,
			@cantidadTotalPedido float,
			@porcReal float


	SELECT @porcTolerancia = ISNULL(LimiteExcesoEntrada,0)
	FROM dbo.IN_AL_MovimientoDetalle movD 
	INNER JOIN dbo.IN_AL_Movimiento mov ON mov.IdMovimiento = movD.IdMovimiento
	INNER JOIN dbo.IN_AL_VariablesSistema var ON var.IdAlmacen = mov.IdAlmacen
	WHERE movD.IdMovimientoDetalle = @pIdMovimientoDetalle



		


	select @cantidadTotalRecepcion = isnull(SUM(isnull(md.Cantidad,0)),0) + @pIdCantidad
	from IN_AL_MovimientoDetalle md
	inner join IN_AL_Movimiento m on m.IdMovimiento = md.IdMovimiento
	where md.idMovimientoDetalle <> @pIdMovimientoDetalle and
	md.IdPedidoDetalle = @pIdPedidoDetalle and
	m.IdTipoMovimiento = 1--Recepción


	--return cast(@cantidadTotalRecepcion as varchar)


	select @cantidadTotalPedido = isnull(max(Cantidad),0)
	from MM_PedidoDetalle pd 
	where --md.idMovimientoDetalle <> @pIdMovimientoDetalle and
	IdPedidoDetalle = @pIdPedidoDetalle 
	

	--return cast(@cantidadTotalPedido as varchar)

	set @porcReal = (@cantidadTotalRecepcion * 1) / @cantidadTotalPedido

	if(@porcReal > (1+@porcTolerancia))
	begin
		set @result = 'La cantidad solicitada sobrepasaría el margen de tolerancia para este material'
	end

--	return cast(@porcReal as varchar)

	return @result

END

