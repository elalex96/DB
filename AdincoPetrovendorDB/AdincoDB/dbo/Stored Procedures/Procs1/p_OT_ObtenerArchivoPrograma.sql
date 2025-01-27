IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'p_OT_ObtenerArchivoPrograma'
    )
    DROP PROCEDURE p_OT_ObtenerArchivoPrograma;
GO
CREATE PROCEDURE p_OT_ObtenerArchivoPrograma (@pID int)
as
    begin

        select
            pa.ID,
            pa.IdOTSolicitud,
            awsd.Bucket,
            awsd.Folder,
            awsd.UUIDAmazon,
            awsd.NombreArchivo,
            awsd.Meta
        FROM
            OT_ProgramaAdjunto pa (NOLOCK)
        JOIN
            AWS_Documentos awsd (NOLOCK)
                ON pa.AWSDocumentoId = awsd.AWSDocumentoId
				AND pa.ID = @pID
        WHERE
            pa.ID = @pID

    end
