
create proc p_SC_Unidades_Cmb
as
begin
	select	IdUnidad,
			Unidad,
			UMB
	from	PV_MM_MaterialUnidad
	where	IsActivo	=	1
end

