
create proc sp_ComprobantesAWSDocumentos_Upd
(
	@AWSDocumentoId		int,
	@FechaPago			date
)
as
begin
	update	ComprobantesAWSDocumentos
	set		FechaPago				=	@FechaPago
	where	AWSDocumentoId			=	@AWSDocumentoId

end