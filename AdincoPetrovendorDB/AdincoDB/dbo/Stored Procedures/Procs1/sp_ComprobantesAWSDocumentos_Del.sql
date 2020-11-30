
create proc sp_ComprobantesAWSDocumentos_Del
(
	@AWSDocumentoId			int	
)
as
begin
	
	
	delete 
	from	ComprobantesAWSDocumentos	
	where	AWSDocumentoId			=	@AWSDocumentoId
				
end