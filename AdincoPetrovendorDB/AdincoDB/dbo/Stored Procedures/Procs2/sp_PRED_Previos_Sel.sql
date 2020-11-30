
create proc sp_PRED_Previos_Sel
(
	@IdPrevio	int
)
as
begin
	select		pv.IdPrevio,
				pv.IdPredio,
				pv.TabuladorIndaabin,
				pv.Vigencia,
				pv.IdGestor,
				pv.IdJefeCampo,
				pv.Descripcion,
				pv.IdTipoBDT,
				pv.IdTipoInstalacion
	from		PRED_Previos					pv
	inner join	PRED_Predios					p
	on			pv.IdPredio						=	p.IdPredio
	inner join	CO_PropietariosAreaContractual	pac
	on			p.IdPropietario					=	pac.IdPropietario
	inner join	CAT_Municipios					m
	on			p.IdMunicipio					=	m.IdMunicipio
	and			p.IdEstado						=	m.IdEstado
	inner join	CAT_Estados						e
	on			p.IdEstado						=	e.IdEstado
	inner join	CO_AreaContractual				ac
	on			ac.IdAreaContractual			=	p.IdAreaContractual
	inner join	CAT_TiposBDT					t
	on			pv.IdTipoBDT						=	t.IdTipoBDT
	where		pv.IdPrevio						=	@IdPrevio
end
