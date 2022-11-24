CREATE  proc sp_PV_MM_MaterialUnidad_Cmb
as
begin
	select		IdUnidad, 
				Unidad
	from		PV_MM_MaterialUnidad
	where		IsActivo				=	1
	and			IsEliminado				=	0
	order by	Unidad
end