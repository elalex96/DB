/*Combo para plantilla xls*/
create proc sp_EN_FrecuenciaEntregable_Lst
as
begin
	select	IdFrecuenciaEntregable,
			FrecuenciaEntregable,
			FrecuenciaIngles
	from	EN_FrecuenciaEntregable
end