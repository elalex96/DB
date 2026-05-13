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

