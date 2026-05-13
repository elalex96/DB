
CREATE Function [dbo].[fn_IN_AL_ValidarReserva]
(
	@pIdAlmacen int,
	@pIdMovimiento int,
	@pIdMovimientoDetalle int,
	@pIdMaterial int,
	@pIdCantidad decimal(14,2)
)
returns varchar(250)
as
begin
	declare @result varchar(250)='',
			@permitirCapturaDeci bit = 0
			

	if isnull(@pIdCantidad,0) <= 0
	begin
		
		set @result='La cantidad debe de ser mayor a cero'
	end

	/*******Validar que no se reserve mas de lo disponible Total******************/
	--if not exists (
	--	select *
	--	from vw_IN_AL_movimientos 
	--	where IdMaterial = @pIdMaterial
	--	and DisponibleTotalAlmacen >= @pIdCantidad and
	--	IdAlmacen = @pIdAlmacen
	--)
	--begin

	--	set @result=@result+'No es posible reservar mas de lo disponible en Almacén'

	--end

	/**********Evitar duplicar el material******************/
	if exists(
		select 1
		from IN_AL_MovimientoDetalle
		where IdMovimiento = @pIdMovimiento and
		IdMaterial = @pIdMaterial and
		idMovimientoDetalle <>@pIdMovimientoDetalle
	)
	begin
		
		set @result=@result+'|Ya existe un registro para este material'

	end

	if @permitirCapturaDeci= 0
	begin
		if (@pIdCantidad % 1) <> 0
		begin
			set @result = 'No se permite la captura de Decimales para este material.'		
		end
	end



	return @result
end



