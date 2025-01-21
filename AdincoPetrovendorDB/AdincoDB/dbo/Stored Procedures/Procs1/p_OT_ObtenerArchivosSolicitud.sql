IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'p_OT_ObtenerArchivosSolicitud'
    )
    DROP PROCEDURE p_OT_ObtenerArchivosSolicitud;
GO
CREATE PROCEDURE p_OT_ObtenerArchivosSolicitud(@pIdOTSolicitud int)
as
    begin
        select
            PA.ID,
            sm.IdOTSolicitud,
            awsd.Bucket,
            awsd.Folder,
            awsd.UUIDAmazon,
            awsd.NombreArchivo,
            awsd.Meta
			
        from
            OT_Solicitud                 s (NOLOCK)
            INNER JOIN
                OT_SolicitudMaterial     sm (NOLOCK)
                    ON s.IdOTSolicitud = sm.IdOTSolicitud
                       AND s.IdOTSolicitud = @pIdOTSolicitud
            INNER JOIN
                OT_ProgramaAdjuntoSemana pa (NOLOCK)
                    ON sm.IdOTSolicitudMaterial = pa.IdOTSolicitudMaterial
            INNER JOIN
                AWS_Documentos           awsd (NOLOCK)
                    ON pa.AWSDocumentoId = awsd.AWSDocumentoId
        where
            s.IdOTSolicitud = @pIdOTSolicitud
        union
        select
            PA.ID,
            s.IdOTSolicitud,
            awsd.Bucket,
            awsd.Folder,
            awsd.UUIDAmazon,
            awsd.NombreArchivo,
            awsd.Meta
        from
            OT_Solicitud           s (NOLOCK)
            INNER JOIN
                OT_ProgramaAdjunto pa (NOLOCK)
                    ON s.IdOTSolicitud = pa.IdOTSolicitud
                       AND s.IdOTSolicitud = @pIdOTSolicitud
            INNER JOIN
                AWS_Documentos     awsd (NOLOCK)
                    ON pa.AWSDocumentoId = awsd.AWSDocumentoId
        where
            s.IdOTSolicitud = @pIdOTSolicitud
    end
