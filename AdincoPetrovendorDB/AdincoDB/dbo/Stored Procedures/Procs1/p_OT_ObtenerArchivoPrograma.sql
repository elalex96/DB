CREATE proc p_OT_ObtenerArchivoPrograma
(
	@pID int
)
as
begin

	select		pa.ID,
				pa.IdOTSolicitud,
				awsd.Bucket,
				awsd.Folder,
				awsd.UUIDAmazon,
				awsd.NombreArchivo,
				awsd.Meta
	from		OT_ProgramaAdjunto		pa
	inner join	AWS_Documentos			awsd
	on			pa.AWSDocumentoId		=	awsd.AWSDocumentoId
	where		pa.ID					=	@pID

end