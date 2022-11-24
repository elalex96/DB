/*Combo para plantilla xls*/
create proc sp_EN_ReceptorEntregable_Lst
as
begin
	select	IdReceptorEntregable,
			ReceptorEntregable
	from	EN_ReceptorEntregable
end