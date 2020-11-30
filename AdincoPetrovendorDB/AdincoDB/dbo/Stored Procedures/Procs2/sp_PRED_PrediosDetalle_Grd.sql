
create proc sp_PRED_PrediosDetalle_Grd
(
	@IdPredio		int
)
as
begin
	select		ct.Logo,
				Contratista				=	ct.RazonSocial,
				p.IdPredio,
				Predio					=	p.Nombre,
				Descripcion				=	p.Descripcion,
				p.IdPropietario,
				Propietario				=	pac.NombrePropietario,
				p.IdMunicipio,
				m.Municipio,
				p.IdEstado,
				e.Estado,
				p.IdAreaContractual,
				AreaContractual			=	ac.NombreAreaContractual,
				p.IdTipoBDT,
				t.TipoBDT,
				p.KilometrosCuadrados,
				pd.IdPredioDetalle,
				pd.Cantidad,
				pd.Concepto,
				pd.PrecioUnitario,
				SubTotal						=	pd.Cantidad * pd.PrecioUnitario,
				Activo							=	cast(1 as bit)
	into		#tmp
	from		PRED_PrediosDetalle				pd
	inner join	PRED_Predios					p
	on			pd.IdPredio						=	p.IdPredio
	inner join	CO_PropietariosAreaContractual	pac
	on			p.IdPropietario					=	pac.IdPropietario
	inner join	CAT_Municipios					m
	on			p.IdMunicipio					=	m.IdMunicipio
	inner join	CAT_Estados						e
	on			p.IdEstado						=	e.IdEstado
	inner join	CO_AreaContractual				ac
	on			ac.IdAreaContractual			=	p.IdAreaContractual
	inner join	CAT_TiposBDT					t
	on			p.IdTipoBDT						=	t.IdTipoBDT
	inner  join	CO_Contrato						c
	on			p.IdAreaContractual				=	c.IdAreaContractual
	inner join	CO_Contratista					ct
	on			ct.IdContratista				=	c.IdContratista
	where		pd.IdPredio						=	@IdPredio
	and			pd.Activo						=	1

	declare		@Total	float
	select		@Total			=	sum(t1.SubTotal)
	from		#tmp			t1

	select		t1.Logo,
				t1.Contratista,
				t1.IdPredio,
				t1.Predio,
				t1.Descripcion,
				t1.IdPropietario,
				t1.Propietario,
				t1.IdMunicipio,
				t1.Municipio,
				t1.IdEstado,
				t1.Estado,
				t1.IdAreaContractual,
				t1.AreaContractual,
				t1.IdTipoBDT,
				t1.TipoBDT,
				t1.KilometrosCuadrados,
				t1.IdPredioDetalle,
				t1.Cantidad,
				t1.Concepto,
				t1.PrecioUnitario,
				Total				=	@Total,
				CantidadConLetra	=	dbo.CantidadConLetra(@Total),
				t1.Activo
	from		#tmp				t1
	
end

