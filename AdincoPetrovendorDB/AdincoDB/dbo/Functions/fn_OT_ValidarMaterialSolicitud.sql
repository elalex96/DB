CREATE Function dbo.fn_OT_ValidarMaterialSolicitud(
	@pIdOTSolicitud int,
	@pIdOTSolicitudMaterial int,
	@pIdSCMaterial int,
	@pCantidad decimal(14,2),
	@pAccion varchar(3),
	@pTipoUsuario int=1 --1.Operador 2.Subcontratista
)
returns varchar(150)
as
begin
	

	declare @cantidadTotal decimal(14,2),
		 @cantidadSolicitada decimal(14,2),
		 @mensaje varchar(150)='',
		 @idSCSubContrato int


	/**********************************************/
	if(@pAccion = 'INS')
	begin

		if exists (
			select 1
			from OT_SolicitudMaterial
			where IdOTSolicitud = @pIdOTSolicitud and
			IdSCMaterial = @pIdSCMaterial
		)
		begin
			set @mensaje = 'No es posible ingresar nuevamente el material en esta OT <br>'
		end 

	end


	/****Obtener subcontrato************/

	SELECT @idSCSubContrato= IdSubContrato
	from OT_Solicitud
	where IdOTSolicitud= @pIdOTSolicitud


	select @cantidadTotal = Cantidad
	from SC_Materiales sc
	where IdSCMaterial = @pIdSCMaterial and
	IdSubContrato = @idSCSubContrato



	select @cantidadSolicitada = isnull(SUM(Cantidad) ,0)
	from OT_SolicitudMaterial sm
	inner join OT_Solicitud  s on s.IdOTSolicitud = sm.IdOTSolicitud and
							s.IsActivo = 1 AND
							s.IdOTEstatus not in (7,8)
	where sm.IdSCMaterial = @pIdSCMaterial and
	sm.IdOTSolicitudMaterial <> @pIdOTSolicitudMaterial 


	--if(@pTipoUsuario = 1)
	--begin
	--	if(@cantidadTotal < (@cantidadSolicitada + @pCantidad))
	--		set @mensaje = @mensaje +  'Ya no es posible solicitar mas este material, se exceder�a lo que permite el SubContrato. Solo puede solicitar hasta ' +
	--						cast((@cantidadTotal - @cantidadSolicitada) as varchar)
	--end

	return @mensaje
end