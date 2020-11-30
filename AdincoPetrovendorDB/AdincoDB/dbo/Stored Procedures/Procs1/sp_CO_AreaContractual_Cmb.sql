
create proc sp_CO_AreaContractual_Cmb
as
begin
	select	ac.IdAreaContractual,
			ac.IdAreaContractualPemex,
			ac.NombreAreaContractual,
			ac.Descripcion,
			ac.SuperficieKm2,
			ac.IdRegion,
			ac.Activo,
			ac.IdActivo,
			ac.IdUbicacionAC,
			ac.IdEstado
	from	CO_AreaContractual		ac
	where	ac.Activo				=	1
end