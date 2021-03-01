Use Petrovendor

go

if exists(select * from sys.procedures where name = 'sp_PV_MM_MaterialUnidad_Cmb')
begin
	drop proc sp_PV_MM_MaterialUnidad_Cmb
end

go

create proc sp_PV_MM_MaterialUnidad_Cmb
as
begin
	select	IdUnidad, 
			Unidad
	from	PV_MM_MaterialUnidad
end