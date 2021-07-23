if exists(select * from sys.procedures where name = 'sp_EN_ReceptorEntregable_Lst')
begin
	drop proc sp_EN_ReceptorEntregable_Lst
end

go
/*Combo para plantilla xls*/
create proc sp_EN_ReceptorEntregable_Lst
as
begin
	select	IdReceptorEntregable,
			ReceptorEntregable
	from	EN_ReceptorEntregable
end