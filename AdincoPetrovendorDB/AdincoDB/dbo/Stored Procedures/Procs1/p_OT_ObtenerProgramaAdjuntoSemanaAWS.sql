			--p_OT_ObtenerProgramaAdjuntoSemanaAWS
create proc p_OT_ObtenerProgramaAdjuntoSemanaAWS
(
	@IdOTSolicitudMaterial	int
)
as
begin
	select		awsd.Bucket,
				awsd.Folder,
				awsd.UUIDAmazon,
				awsd.NombreArchivo,
				awsd.Meta
	from		[Adinco]..[OT_ProgramaAdjuntoSemana]	otpas
	inner join	[Adinco]..[AWS_Documentos]				awsd
	on			otpas.AWSDocumentoId					=		awsd.AWSDocumentoId
	where		otpas.IdOTSolicitudMaterial				=		@IdOTSolicitudMaterial--1
end

