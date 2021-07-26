if exists (select * from sys.procedures where name =  'sp_EN_Area_Lst')
begin
	drop proc sp_EN_Area_Lst
end

go
/*Combo para plantilla xls*/
create proc sp_EN_Area_Lst
(
	@IdContrato		int
)
as
begin
	select	idArea,
			NombreArea,
			idContrato
			Activo
	from	EN_Area
	where	idContrato	=	@IdContrato
	and		Activo		=	1
end

go

--exec sp_EN_Area_Lst 3