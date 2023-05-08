
create proc sp_FacturasAWSDocumentos_Ins
(
	--@IdFacturaAWSDocumento	int,
	@IdFactura				int,
	@AWSDocumentoId			int,
	@IdUsuario				int
)
as
begin
	declare @IdFacturaAWSDocumento	int
	select @IdFacturaAWSDocumento	=	isnull(max(IdFacturaAWSDocumento),0)+1 from FacturasAWSDocumentos

	select @IdFacturaAWSDocumento

	insert into FacturasAWSDocumentos	
				(
					IdFacturaAWSDocumento,
					IdFactura,
					AWSDocumentoId,
					CreadoPor,
					CreadoEl
		
				)
			values
				(
					@IdFacturaAWSDocumento,
					@IdFactura,
					@AWSDocumentoId,
					@IdUsuario,
					getdate()
				)
end