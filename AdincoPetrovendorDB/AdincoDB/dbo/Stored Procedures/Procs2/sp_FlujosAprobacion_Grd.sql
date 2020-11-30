CREATE proc sp_FlujosAprobacion_Grd
@pIdContratista int
as
begin
	select		fa.IdContratista,
				fa.TipoFlujoAprobacionId,				
				fa.FlujoAprobacionId,
				fa.Descripcion,
				TipoAprobacion=fat.Descripcion
	from		AP_FlujoAprobacion			fa
	inner join	AP_FlujoAprobacionTipos		fat
	on			fa.TipoFlujoAprobacionId	=	fat.TipoFlujoAprobacionId
	where		Activo						=	1 and
	fa.IdContratista = @pIdContratista

end



