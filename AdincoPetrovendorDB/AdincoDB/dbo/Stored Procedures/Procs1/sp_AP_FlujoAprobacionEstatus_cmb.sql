
create proc sp_AP_FlujoAprobacionEstatus_cmb
(
	@pIdContrato				int,
	@pIdContratista				int,
	@pTipoFlujoAprobacionId		int
)
as
begin
	select		fae.FlujoAprobacionEstatusId,
				fa.FlujoAprobacionId,
				fae.TipoFlujoAprobacionId,
				fae.Descripcion,
				fae.Orden,
				fae.CreadoEl,
				c.IdContrato,
				c.IdContratista
	from		AP_FlujoAprobacionEstatus	fae
	left join	AP_FlujoAprobacion			fa
	on			fae.TipoFlujoAprobacionId	=	fa.TipoFlujoAprobacionId
	--and			fae.FlujoAprobacionId		=	fa.FlujoAprobacionId
	left join	CO_Contrato					c
	on			c.IdContratista				=	fa.IdContratista
	where		c.IdContrato				=	@pIdContrato
	and			c.IdContratista				=	@pIdContratista
	and			fa.TipoFlujoAprobacionId	=	@pTipoFlujoAprobacionId
end
