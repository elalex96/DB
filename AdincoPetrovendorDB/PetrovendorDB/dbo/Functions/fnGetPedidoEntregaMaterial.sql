
CREATE FUNCTION dbo.fnGetPedidoEntregaMaterial
(
	@pIdAlmacen int,
	@pIdMaterial int,
	@pCantidadEntrega float
)
RETURNS varchar(250)
AS
BEGIN

	declare @ueps int,
			@IdMovimientoDetalle int

	--Obtener UEPS o PEPS
	
	select @ueps = UEPS
	from IN_Almacen
	where IdAlmacen = @pIdAlmacen


	--Obtener el ultimo movimiento para el material
	if(@ueps =1 )
	begin
		select top 1	@IdMovimientoDetalle =  md.IdMovimientoDetalle
		from IN_AL_MovimientoDetalle md
		inner join MM_PedidoDetalle pd on pd.IdPedidoDetalle = md.IdPedidoDetalle
		inner join IN_AL_Movimiento m on m.IdMovimiento = md.IdMovimiento
		where md.Disponible > 0 and
		pd.IdMaterialVendedor = @pIdMaterial and
		m.IdTipoMovimiento = 1 --recepcion
		order by m.FechaMovimiento desc

	end
	else
	begin
		select top 1	@IdMovimientoDetalle =  md.IdMovimientoDetalle
		from IN_AL_MovimientoDetalle md
		inner join MM_PedidoDetalle pd on pd.IdPedidoDetalle = md.IdPedidoDetalle
		inner join IN_AL_Movimiento m on m.IdMovimiento = md.IdMovimiento
		where md.Disponible > 0 and
		pd.IdMaterialVendedor = @pIdMaterial and
		m.IdTipoMovimiento = 1 --recepcion
		order by m.FechaMovimiento asc
	end

	return isnull(@IdMovimientoDetalle,0)

END


