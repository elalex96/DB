IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'p_OT_ConsultarProgramaAdjunto'
    )
    DROP PROCEDURE p_OT_ConsultarProgramaAdjunto;
GO
create proc [dbo].[p_OT_ConsultarProgramaAdjunto] (@pIdOTSolicitud int)
as
    begin

        select
            pa.ID,
            pa.IdOTSolicitud,
            NombreAdjunto = d.NombreArchivo,
            Adjunto       = '',
            pa.CreadoPor,
            pa.CreadoEl,
            pa.AWSDocumentoId,
            UUIDAmazon,
            Bucket
        FROM
            OT_ProgramaAdjunto pa (NOLOCK)
       JOIN
                AWS_Documentos d (NOLOCK)
                    on pa.AWSDocumentoId = d.AWSDocumentoId
					AND PA.IdOTSolicitud = @pIdOTSolicitud
        where
            PA.IdOTSolicitud = @pIdOTSolicitud
    end

