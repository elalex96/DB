
create proc sp_PRED_PrevioBDT_Rpt
(
	@IdPrevio	int
)
as
begin
	select		ct.Logo,
				Contratista						=	ct.RazonSocial,
				pd.IdPredio,
				pd.Nombre,
				--pd.IdPropietario,
				p.NombrePropietario,
				--pd.IdAreaContractual,
				a.NombreAreaContractual,
				--pd.IdMunicipio,
				m.Municipio,
				--pd.IdEstado,
				e.Estado,
				--pd.IdTipoBDT,
				t.TipoBDT,
				pv.TabuladorIndaabin,
				Vigencia						=	cast(pv.Vigencia as date),
				pv.Descripcion,
				--pv.IdGestor,
				Gestor							=	g.Nombre,
				--pv.IdJefeCampo,
				JefeCampo						=	jc.Nombre,
				pvd.Cantidad,
				pvd.Concepto,
				pvd.PrecioUnitario,
				Total							=	pvd.Cantidad*pvd.PrecioUnitario
	into		#tmp
	from		PRED_Previos					pv
	inner join	PRED_Predios					pd
	on			pv.IdPredio						=	pd.IdPredio
	inner join	CO_PropietariosAreaContractual	p
	on			p.IdPropietario					=	pd.IdPropietario
	inner join	CO_AreaContractual				a
	on			a.IdAreaContractual				=	pd.IdAreaContractual
	inner join	CAT_Municipios					m
	on			m.IdMunicipio					=	pd.IdMunicipio
	inner join	CAT_Estados						e
	on			e.IdEstado						=	m.IdEstado
	and			e.IdEstado						=	pd.IdEstado
	inner join	CAT_TiposBDT					t
	on			pv.IdTipoBDT					=	t.IdTipoBDT
	inner join	PRED_PreviosDetalle				pvd
	on			pvd.IdPrevio					=	pv.IdPrevio
	inner join	AP_Usuario						g
	on			pv.IdGestor						=	g.UsuarioID
	inner join	AP_Usuario						jc
	on			pv.IdJefeCampo					=	jc.UsuarioID
	inner  join	CO_Contrato						c
	on			p.IdAreaContractual				=	c.IdAreaContractual
	inner join	CO_Contratista					ct
	on			ct.IdContratista				=	c.IdContratista
	where		pv.IdPrevio						=	@IdPrevio
	and			pvd.Activo						=	1

	declare		@total	float
	select		@total = sum(Total) from #tmp

	select		t.Logo,
				t.Contratista,
				t.IdPredio,
				Predio						=	t.Nombre,
				Propietario					=	t.NombrePropietario,
				AreaContractual				=	t.NombreAreaContractual,
				t.Municipio,
				t.Estado,
				t.TipoBDT,
				t.TabuladorIndaabin,
				t.Vigencia,
				t.Descripcion,
				t.Gestor,
				t.JefeCampo,
				t.Cantidad,
				t.Concepto,
				t.PrecioUnitario,
				Total,
				CantidadLetra				=	dbo.CantidadConLetra(@Total)
	from		#tmp						t
end

