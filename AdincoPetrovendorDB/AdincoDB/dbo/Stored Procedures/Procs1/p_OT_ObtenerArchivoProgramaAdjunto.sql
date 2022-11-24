CREATE proc [dbo].[p_OT_ObtenerArchivoProgramaAdjunto]
(
	@pID int
)
as
begin

	select		PA.ID,
				
				awsd.Bucket,
				awsd.Folder,
				awsd.UUIDAmazon,
				awsd.NombreArchivo,
				awsd.Meta
	from		OT_ProgramaAdjunto		pa
	inner join	AWS_Documentos					awsd
	on			pa.AWSDocumentoId				=	awsd.AWSDocumentoId	
	where		pa.ID							=	@pID

end