
create proc sp_CO_PropietariosAreaContractual_Cmb
(
	@IdAreaContractual	int
)
as
begin
	select		pac.IdPropietario,
				pac.IdAreaContractual,
				pac.NombrePropietario,
				pac.KM2,
				pac.FechaIniPago,
				pac.RFC,
				pac.Correo,
				pac.Telefono,
				pac.Direccion,
				pac.Bit_Activo
	from		CO_PropietariosAreaContractual	pac
	where		pac.Bit_Activo					=		1
	and			((pac.IdAreaContractual			=		@IdAreaContractual)	or	@IdAreaContractual	=	-1)
end

--sp_CO_PropietariosAreaContractual_Cmb 10000