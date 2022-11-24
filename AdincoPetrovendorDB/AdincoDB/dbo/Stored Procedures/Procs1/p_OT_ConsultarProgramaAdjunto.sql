

create proc [dbo].[p_OT_ConsultarProgramaAdjunto] (@pIdOTSolicitud int)
as
begin

    select pa.ID,
           pa.IdOTSolicitud,
           NombreAdjunto = d.NombreArchivo,
           Adjunto = '',
           pa.CreadoPor,
           pa.CreadoEl,
           pa.AWSDocumentoId,
           UUIDAmazon,
           Bucket
    from OT_ProgramaAdjunto pa (NOLOCK)
        inner join AWS_Documentos d (NOLOCK)
            on pa.AWSDocumentoId = d.AWSDocumentoId
    where IdOTSolicitud = @pIdOTSolicitud
end
