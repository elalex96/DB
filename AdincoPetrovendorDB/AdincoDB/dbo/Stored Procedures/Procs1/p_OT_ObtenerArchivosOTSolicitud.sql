IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'p_OT_ObtenerArchivosOTSolicitud'
    )
    DROP PROCEDURE p_OT_ObtenerArchivosOTSolicitud --2918
GO
CREATE proc p_OT_ObtenerArchivosOTSolicitud (@pIdOTSolicitud int)
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
            OT_SolicitudMaterial         sm (NOLOCK)
            JOIN
                OT_ProgramaAdjuntoSemana pa (NOLOCK)
                    ON sm.IdOTSolicitudMaterial = pa.IdOTSolicitudMaterial
					AND	  sm.IdOTSolicitud = @pIdOTSolicitud
            JOIN
                AWS_Documentos           awsd (NOLOCK)
                    on pa.AWSDocumentoId = awsd.AWSDocumentoId
        where
            sm.IdOTSolicitud = @pIdOTSolicitud
        union
        select
            pa.ID,
            PA.IdOTSolicitud,
            awsd.Bucket,
            awsd.Folder,
            awsd.UUIDAmazon,
            awsd.NombreArchivo,
            awsd.Meta
        from
            [dbo].[OT_ProgramaAdjunto] pa (NOLOCK)
            JOIN
                AWS_Documentos         awsd (NOLOCK)
                    on pa.AWSDocumentoId = awsd.AWSDocumentoId
                       AND PA.IdOTSolicitud = @pIdOTSolicitud
        WHERE
            PA.IdOTSolicitud = @pIdOTSolicitud

    end
