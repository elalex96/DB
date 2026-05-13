
create proc sp_FacturasAWSDocumentos_Upd
(
	@AWSDocumentoId		int,
	@FechaPago			date
)
as
begin
	update	FacturasAWSDocumentos
	set		FechaPago				=	@FechaPago
	where	AWSDocumentoId			=	@AWSDocumentoId

end