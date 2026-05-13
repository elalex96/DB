
create proc sp_PRED_Predios_Cmb
as
begin
	select		p.IdPredio,
				Propietario						=	NombrePropietario,
				Predio							=	p.Nombre 
	from		PRED_Predios	p
	inner join	CO_PropietariosAreaContractual	pac
	on			p.IdPropietario					=	pac.IdPropietario
	

end

