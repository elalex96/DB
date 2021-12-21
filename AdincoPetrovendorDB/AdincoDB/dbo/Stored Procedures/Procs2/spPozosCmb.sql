if exists (select * from sys.procedures where name = 'spPozosCmb')
begin
	drop proc spPozosCmb
end

go

create proc spPozosCmb
(
	@IdContrato	int
)
as
begin
	select		Id					=	IdInstalacion,
				Nombre				=	NombreInstalacion 
	FROM		dbo.CO_Instalacion	i
	INNER JOIN	dbo.CO_Contrato		c 
	ON			c.IdAreaContractual =	i.IdAreaContractual
	WHERE		c.IdContrato		=	@IdContrato 
	AND			i.Activo			=	1
end

