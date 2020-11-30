Create Function dbo.fn_IN_AL_ValidarEntrega(
@pIdMovimiento int,
@pIdMovimientoDetalle int,
@pIdMaterial int,
@pCantidadEntrega decimal(14,2)
)
returns varchar(250)
as
begin

	declare @result varchar(250),
			@permitirCapturaDeci bit = 0

	/************VALIDAR SI SE PERMITEN DECIMALES**************************/
	if @permitirCapturaDeci= 0
	begin
		if (@pCantidadEntrega % 1) <> 0
		begin
			set @result = '|No se permite la captura de Decimales para este material.'		
		end
	end

	/***************************VALIDAR QUE NO SE AGREGUE MAS DE UNA VEZ UN MISMO MATERIAL****************/
	if(
		select count( distinct md.IdMovimientoDetalle)
		from IN_AL_MovimientoDetalle md
		inner join IN_AL_Movimiento m on m.IdMovimiento = md.IdMovimiento
		--inner join IN_AL_EntregaRecepcion rel on rel.IdMovimientoDetEntrega = md.IdMovimientoDetalle
		--inner join IN_AL_MovimientoDetalle rec on rec.IdMovimientoDetalle = rel.IdMovimientoDetRecepcion
		--inner join MM_PedidoDetalle pd on pd.IdPedidoDetalle = rec.IdPedidoDetalle
		where m.IdMovimiento = @pIdMovimiento and
		m.IsEliminado = 0 and
		md.IdMaterial = @pIdMaterial and
		md.IdMovimientoDetalle <> @pIdMovimientoDetalle --No considerar el registro actual
	) > 0
	begin
		set @result = @result + '|Ya existe un registro de material para este movimiento de entrega.'
		
	end

	return isnull(@result,'')
end


