
create proc sp_CAT_TipoInstalacion_Cmb
as
begin
	select	IdTipoInstalacion,
			TipoInstalacion 
	from	CAT_TipoInstalacion
end