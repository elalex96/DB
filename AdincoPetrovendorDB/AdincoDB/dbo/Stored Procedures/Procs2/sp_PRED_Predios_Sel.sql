
create proc sp_PRED_Predios_Sel
(
	@IdPredio	int
)
as
begin
	select		p.IdPredio,
				p.IdPropietario,
				pac.NombrePropietario,
				p.IdMunicipio,
				m.Municipio,
				p.IdEstado,
				e.Estado,
				p.IdAreaContractual,
				ac.NombreAreaContractual,
				p.KilometrosCuadrados,
				p.Nombre
	from		PRED_Predios					p
	inner join	CO_PropietariosAreaContractual	pac
	on			p.IdPropietario					=	pac.IdPropietario
	inner join	CAT_Municipios					m
	on			p.IdMunicipio					=	m.IdMunicipio
	inner join	CAT_Estados						e
	on			p.IdEstado						=	e.IdEstado
	inner join	CO_AreaContractual				ac
	on			ac.IdAreaContractual			=	p.IdAreaContractual
	where		p.IdPredio						=	@IdPredio
	and			p.Activo						=	1
end