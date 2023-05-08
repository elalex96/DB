
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
	if(@AWSDocumentoId = 0)
	begin
		select @AWSDocumentoId = null
	end
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


--select OBJECT_NAME(object_id),* from sys.columns where name like '%UUID%'

