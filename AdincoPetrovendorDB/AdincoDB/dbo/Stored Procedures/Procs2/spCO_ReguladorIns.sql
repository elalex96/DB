if exists(select * from sys.procedures where name = 'spCO_ReguladorIns')
begin
	drop proc spCO_ReguladorIns
end

go

create proc spCO_ReguladorIns
(
	@regulador			varchar(50),
	@nombreRegulador	varchar(max),
	@AWSDocumentoId		int
)
as
begin
	--declare @idRegulador int

	--select @idRegulador  = isnull(max(IdRegulador),0)+1 from CO_Regulador

	if not exists (select * from CO_Regulador  where NombreRegulador = @NombreRegulador)
	begin
		insert into CO_Regulador 
					(
						--IdRegulador,
						Regulador,
						NombreRegulador,
						AWSDocumentoId
					)
				values
					(
						--@idRegulador,
						@regulador,
						@nombreRegulador,
						@AWSDocumentoId
					)
		select		Error	=	0
	end
	else
	begin
		select		Error	=	1
	end
end