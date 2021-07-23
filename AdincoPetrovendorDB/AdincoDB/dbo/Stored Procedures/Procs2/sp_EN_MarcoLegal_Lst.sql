if exists (select * from sys.procedures where name = 'sp_EN_MarcoLegal_Lst')
begin
	drop proc sp_EN_MarcoLegal_Lst
end

go
/*Combo para plantilla xls*/
create proc sp_EN_MarcoLegal_Lst
as
begin
	select	IdMarcoLegal,
			MarcoLegal,
			IsInterno,
			CreadoPor,
			ModificadoPor,
			CreadoEn,
			ModificadoEn,
			Activo,
			BitJOA,
			MarcoLegalIngles
	from	EN_MarcoLegal
end