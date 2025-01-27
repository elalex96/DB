IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'p_OT_ObtenerArchivosOTSolicitudMaterial'
    )
    DROP PROCEDURE p_OT_ObtenerArchivosOTSolicitudMaterial	
GO
CREATE proc p_OT_ObtenerArchivosOTSolicitudMaterial
    (
        @pIdOTSolicitudMaterial int,
        @del                    datetime,
        @al                     datetime
    )
as
    BEGIN

        SELECT
            PA.ID,
            sm.IdOTSolicitud,
            awsd.Bucket,
            awsd.Folder,
            awsd.UUIDAmazon,
            awsd.NombreArchivo,
            awsd.Meta,
            PA.FechaInicioSemana,
            PA.FechaFinSemana
        from
            OT_ProgramaAdjuntoSemana pa (NOLOCK)
            JOIN
                AWS_Documentos       awsd (NOLOCK)
                    on pa.AWSDocumentoId = awsd.AWSDocumentoId
                       AND PA.IdOTSolicitudMaterial = @pIdOTSolicitudMaterial
                       AND PA.FechaInicioSemana = @del
                       AND PA.FechaFinSemana = @al
            JOIN
                OT_SolicitudMaterial sm (NOLOCK)
                    on sm.IdOTSolicitudMaterial = pa.IdOTSolicitudMaterial
            JOIN
                OT_Solicitud         s (NOLOCK)
                    on s.IdOTSolicitud = sm.IdOTSolicitud
        WHERE
            PA.IdOTSolicitudMaterial = @pIdOTSolicitudMaterial
            AND PA.FechaInicioSemana = @del
            AND PA.FechaFinSemana = @al

    end