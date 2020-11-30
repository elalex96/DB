
create proc p_SC_Subcontrato_Cmb
as
begin
	
	select	IdSubcontratista,
			RFC,
			RazonSocial,
			NombreComercial 
	from 	Adinco..PV_Subcontratista
	where	IsActivo					=	1
end