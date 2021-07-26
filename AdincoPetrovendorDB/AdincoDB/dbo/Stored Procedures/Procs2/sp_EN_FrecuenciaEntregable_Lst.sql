if exists (select * from sys.procedures where name = 'sp_EN_FrecuenciaEntregable_Lst')
begin
	drop proc sp_EN_FrecuenciaEntregable_Lst
end

go
/*Combo para plantilla xls*/
create proc sp_EN_FrecuenciaEntregable_Lst
as
begin
	select	IdFrecuenciaEntregable,
			FrecuenciaEntregable,
			FrecuenciaIngles
	from	EN_FrecuenciaEntregable
end