
create proc spComprobantesPagosGrd
(
	@IdComprobante	int
)
as
begin
	select		faws.IdComprobante,
				awsd.AWSDocumentoId,
				awsd.Bucket,
				awsd.Folder,
				awsd.UUIDAmazon,
				awsd.NombreArchivo,
				awsd.Meta,
				awsd.HashSHA256,
				faws.FechaPago
	from		ComprobantesAWSDocumentos	faws
	inner join	AWS_Documentos				awsd
	on			faws.AWSDocumentoId			=	awsd.AWSDocumentoId
	where		faws.IdComprobante			=	@IdComprobante
end

