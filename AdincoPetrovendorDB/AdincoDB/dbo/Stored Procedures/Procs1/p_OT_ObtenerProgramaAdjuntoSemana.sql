-- p_OT_ObtenerProgramaAdjuntoSemana 1
CREATE PROC p_OT_ObtenerProgramaAdjuntoSemana
(@pID                    INT      = NULL, 
 @pIdOTSolicitudMaterial INT      = NULL, 
 @pFechaInicioSemana     DATETIME = NULL, 
 @pFechaFinSemana        DATETIME = NULL
)
AS
    BEGIN
        SELECT ps.ID, 
               ps.IdOTSolicitudMaterial, 
               ps.FechaInicioSemana, 
               ps.FechaFinSemana,
               --ps.Adjunto,
               NombreArchivo = docs.NombreArchivo, 
               ps.CreadoPor, 
               ps.CreadoEl, 
               docs.Folder, 
               docs.UUIDAmazon, 
               docs.Bucket, 
               docs.AWSDocumentoId, 
               docs.Meta
        FROM [OT_ProgramaAdjuntoSemana] ps
             INNER JOIN AWS_Documentos docs ON ps.AWSDocumentoId = docs.AWSDocumentoId
        WHERE(ps.IdOTSolicitudMaterial = @pIdOTSolicitudMaterial
              AND CONVERT(VARCHAR, FechaInicioSemana, 112) = CONVERT(VARCHAR, @pFechaInicioSemana, 112)
              AND CONVERT(VARCHAR, FechaFinSemana, 112) = CONVERT(VARCHAR, @pFechaFinSemana, 112)
              AND @pID IS NULL)
             OR ID = @pID;
    END