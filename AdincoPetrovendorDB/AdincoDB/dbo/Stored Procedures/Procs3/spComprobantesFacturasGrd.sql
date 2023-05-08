
create proc spComprobantesFacturasGrd
(
	@IdFactura	int
)
as
begin
	select		faws.IdFactura,
				awsd.AWSDocumentoId,
				awsd.Bucket,
				awsd.Folder,
				awsd.UUIDAmazon,
				awsd.NombreArchivo,
				awsd.Meta,
				awsd.HashSHA256,
				faws.FechaPago
	from		FacturasAWSDocumentos	faws
	inner join	AWS_Documentos			awsd
	on			faws.AWSDocumentoId		=	awsd.AWSDocumentoId
	where		IdFactura				=	@IdFactura
end

