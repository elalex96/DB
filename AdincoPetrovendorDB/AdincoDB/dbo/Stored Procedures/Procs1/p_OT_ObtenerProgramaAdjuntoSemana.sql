
-- p_OT_ObtenerProgramaAdjuntoSemana 1
CREATE PROC [dbo].[p_OT_ObtenerProgramaAdjuntoSemana]
(
    @pID INT = NULL,
    @pIdOTSolicitudMaterial INT = NULL,
    @pFechaInicioSemana DATETIME = NULL,
    @pFechaFinSemana DATETIME = NULL
)
AS
BEGIN
    SELECT OT_ProgramaAdjuntoSemana.ID,
           OT_ProgramaAdjuntoSemana.IdOTSolicitudMaterial,
           OT_ProgramaAdjuntoSemana.FechaInicioSemana,
           OT_ProgramaAdjuntoSemana.FechaFinSemana,
           NombreArchivo = AWS_Documentos.NombreArchivo,
           OT_ProgramaAdjuntoSemana.CreadoPor,
           OT_ProgramaAdjuntoSemana.CreadoEl,
           AWS_Documentos.Folder,
           AWS_Documentos.UUIDAmazon,
           AWS_Documentos.Bucket,
           AWS_Documentos.AWSDocumentoId,
           AWS_Documentos.Meta
    FROM OT_ProgramaAdjuntoSemana (NOLOCK)
        INNER JOIN AWS_Documentos (NOLOCK)
            ON OT_ProgramaAdjuntoSemana.AWSDocumentoId = AWS_Documentos.AWSDocumentoId
    WHERE (
              OT_ProgramaAdjuntoSemana.IdOTSolicitudMaterial = @pIdOTSolicitudMaterial
              AND CONVERT(VARCHAR, FechaInicioSemana, 112) = CONVERT(VARCHAR, @pFechaInicioSemana, 112)
              AND CONVERT(VARCHAR, FechaFinSemana, 112) = CONVERT(VARCHAR, @pFechaFinSemana, 112)
              AND @pID IS NULL
          )
          OR ID = @pID;
END
