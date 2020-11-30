-- p_AP_FlujoAprobacionTipos_cmb 1,1
CREATE proc p_AP_FlujoAprobacionTipos_cmb
(
	@pIdContrato	int,
	@pIdContratista	int
)
as
begin
	select		TipoFlujoAprobacionId		=	fat.TipoFlujoAprobacionId,
				Descripcion					=	fat.Descripcion
				
	from		AP_FlujoAprobacionTipos		fat
	left join	AP_FlujoAprobacion			fa
	on			fat.TipoFlujoAprobacionId	=	fa.TipoFlujoAprobacionId
	left join	CO_Contrato					c
	on			c.IdContratista				=	fa.IdContratista
	group by fat.TipoFlujoAprobacionId,fat.Descripcion
	--where		--c.IdContrato				=	@pIdContrato
		--		c.IdContratista				=	@pIdContratista
end




