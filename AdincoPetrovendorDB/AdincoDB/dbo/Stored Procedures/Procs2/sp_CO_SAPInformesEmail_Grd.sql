
create proc sp_CO_SAPInformesEmail_Grd

as
begin

	select		sie.IdInformesEmail,
				sie.IdContratista,
				sie.Email
	from		CO_SAPInformesEmail			sie
	inner join	CO_SAPContratista_Planta	scp
	on			sie.IdContratista			=	scp.IdContratista
	
end


