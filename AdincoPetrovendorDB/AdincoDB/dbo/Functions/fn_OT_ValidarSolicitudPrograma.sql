-- fn_OT_ValidarSolicitudPrograma
CREATE Function [dbo].[fn_OT_ValidarSolicitudPrograma](
@pIdOTSolicitudPrograma	int,
@pIdOTSolicitudMaterial	int,
@pAnio	smallint,
@pMes	tinyint,
@pCantidad	decimal(14,5)
)
returns varchar(550)
begin

	declare @cantidadMax decimal(14,5),
			@cantidadSolicitadaActual decimal(14,5),
			@error varchar(550)='',
			@descripcionMAT VARCHAR(510),
			@nombreMes varchar(20)

	select @nombreMes = case when @pMes = 1 then 'Enero' 
							when @pMes = 2 then 'Febrero' 
							when @pMes = 3 then 'Marzo' 
							when @pMes = 4 then 'Abril' 
							when @pMes = 5 then 'Mayo' 
							when @pMes = 6 then 'Junio' 
							when @pMes = 7 then 'Julio' 
							when @pMes = 8 then 'Agosto' 
							when @pMes = 9 then 'Septiembre' 
							when @pMes = 10 then 'Octubre' 
							when @pMes = 11 then 'Noviembre' 
							when @pMes = 12 then 'Diciembre' 
						end

	select @cantidadMax = isnull(sm.Cantidad,0),
		@descripcionMAT = scmat.Descripcion
	from OT_SolicitudMaterial  SM
	INNER JOIN OT_Solicitud sol on sol.IdOTSolicitud = SM.IdOTSolicitud
	inner join SC_Materiales scmat on scmat.IdSCMaterial = sm.IdSCMaterial and
								scmat.IdSubCOntrato = sol.IdSubContrato
	where IdOTSolicitudMaterial = @pIdOTSolicitudMaterial

	select @cantidadSolicitadaActual = isnull(sum(cantidad),0)
	from OT_SolicitudPrograma
	where IdOTSolicitudMaterial = @pIdOTSolicitudMaterial and
	IdOTSolicitudPrograma <> @pIdOTSolicitudPrograma

	if((@cantidadSolicitadaActual +@pCantidad) > @cantidadMax)
	begin
		set @error = 'No es posible programar el material '+ @descripcionMAT + ' para el mes de ' + @nombreMes + ' ' + cast(@pAnio as varchar)+',se debe de distribuir la cantidad exacta. Disponible para OT: '+
		cast(@cantidadMax - @cantidadSolicitadaActual as varchar)
	end

	return @error


end

