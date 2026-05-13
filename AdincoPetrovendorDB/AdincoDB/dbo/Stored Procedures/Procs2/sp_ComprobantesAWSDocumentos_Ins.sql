
create proc sp_ComprobantesAWSDocumentos_Ins
(
	@IdComprobante			int,
	@AWSDocumentoId			int,
	@IdUsuario				int
)
as
begin
	declare @IdComprobanteAWSDocumento	int
	select @IdComprobanteAWSDocumento	=	isnull(max(IdComprobanteAWSDocumento),0)+1 from ComprobantesAWSDocumentos

	--select @IdComprobanteAWSDocumento

	insert into ComprobantesAWSDocumentos	
				(
					IdComprobanteAWSDocumento,
					IdComprobante,
					AWSDocumentoId,
					CreadoPor,
					CreadoEl
				)
			values
				(
					@IdComprobanteAWSDocumento,
					@IdComprobante,
					@AWSDocumentoId,
					@IdUsuario,
					getdate()
				)

	select * from ComprobantesAWSDocumentos
end

