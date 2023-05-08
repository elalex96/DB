create procedure p_CO_CentroCostosUsuarios
as
begin
	select 
	UCC.Id,
	CC.CentroCosto,
	UP.Nombre,
	UCC.CreadoEl
	from AP_UsuarioCentroCosto as UCC
	join Petrovendor..CC_CentroCosto as CC on UCC.IdCentroCosto = CC.IdCentroCosto
	join Petrovendor..S_Usuario as UP on UCC.IdUsuario = UP.IdUsuarioADINCO
	group by 
	UCC.Id,
	UP.Nombre,
	CC.CentroCosto,
	UCC.CreadoEl
	order by UCC.Id desc
end