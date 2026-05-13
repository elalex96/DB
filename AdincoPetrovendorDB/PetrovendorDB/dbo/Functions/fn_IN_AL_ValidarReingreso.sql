
CREATE Function [dbo].[fn_IN_AL_ValidarReingreso](
@pIdMovimiento int,
@pIdMovimientoDetalle int,
@pIMovimientoEntregaDetalle int,
@pCantidadReingreso decimal(14,2)
)
returns varchar(250)
as
begin

	declare @result varchar(250)='',
			@permitirCapturaDeci bit = 0

	/***************************VALIDAR QUE NO SE AGREGUE MAS DE UNA VEZ UN MISMO MATERIAL****************/
	if(
		select count( distinct md.IdMovimientoDetalle)
		from IN_AL_MovimientoDetalle md
		inner join IN_AL_Movimiento m on m.IdMovimiento = md.IdMovimiento
		inner join IN_AL_RecepcionReingreso rel on rel.IdMovimientoDetReingreso = md.IdMovimientoDetalle
		inner join IN_AL_MovimientoDetalle ent on ent.IdMovimientoDetalle = rel.IdMovimientoDetEntrega	
		where m.IdMovimiento = @pIdMovimiento and
		m.IsEliminado = 0 and
		rel.IdMovimientoDetEntrega = @pIMovimientoEntregaDetalle and
		md.IdMovimientoDetalle <> @pIdMovimientoDetalle --No considerar el registro actual
	) > 0
	begin
		set @result = 'Ya existe un registro con la misma referencia de Movimiento de Entrega.'
		
	end

	/*********Validar que la cantidad que se quiere reingresar no sea mayor a la cantidad que se recibió en el movimiento*********************/
	declare @cantidadEntrega decimal(14,2)

	select @cantidadEntrega = isnull(Cantidad,0)
	from IN_AL_MovimientoDetalle md
	inner join IN_AL_Movimiento m on m.idMovimiento=md.IdMovimiento
	where md.IdMovimientoDetalle = @pIMovimientoEntregaDetalle and
	m.idTipoMovimiento = 2 and--Entrega
	isnull(m.IdUsuarioAutorizo,0) > 0 --Esté autorizada


	if(@pCantidadReingreso > @cantidadEntrega)
	begin
		set @result = @result+'|La cantidad de reingreso no puede ser mayor a la que se entregó en el movimiento de entrega'
	end

	
	/************VALIDAR SI SE PERMITEN DECIMALES**************************/
	if @permitirCapturaDeci= 0
	begin
		if (@pCantidadReingreso % 1) <> 0
		begin
			set @result = 'No se permite la captura de Decimales para este material.'		
		end
	end
	


	return isnull(@result,'')
end

