
create proc sp_FacturasAWSDocumentos_Del
(
	@AWSDocumentoId			int	
)
as
begin
	
	
	delete 
	from	FacturasAWSDocumentos	
	where	AWSDocumentoId			=	@AWSDocumentoId
				
end