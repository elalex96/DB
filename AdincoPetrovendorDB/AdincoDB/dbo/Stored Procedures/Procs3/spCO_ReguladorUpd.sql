
create proc spCO_ReguladorUpd
(
	@idRegulador		int,
	@regulador			varchar(50),
	@nombreRegulador	varchar(max),
	@AWSDocumentoId		int
)
as
begin
	if(@AWSDocumentoId = 0)
	begin
		select @AWSDocumentoId = AWSDocumentoId from CO_Regulador  where IdRegulador	=	@idRegulador
	end

	--select @AWSDocumentoId

	if not exists (select * from CO_Regulador  where NombreRegulador = @NombreRegulador and IdRegulador	<>	@idRegulador)
	begin
		update	CO_Regulador 
		set		Regulador			=	@regulador,
				NombreRegulador		=	@nombreRegulador,
				AWSDocumentoId		=	@AWSDocumentoID
		where	IdRegulador			=	@idRegulador
						
		select		Error	=	0
	end
	else
	begin
		select		Error	=	1
	end
end

