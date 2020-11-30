--p_OT_ObtenerProgramaAdjuntoSemanaAWS 2

CREATE PROC p_OT_ObtenerProgramaAdjuntoSemanaAWS
(@IdOTSolicitudMaterial INT, 
 @fechaIni              DATETIME, 
 @fechaFin              DATETIME
)
AS
    BEGIN
        SELECT awsd.Bucket, 
               awsd.Folder, 
               awsd.UUIDAmazon, 
               awsd.NombreArchivo, 
               awsd.Meta
        FROM [Adinco]..[OT_ProgramaAdjuntoSemana] otpas
             INNER JOIN [Adinco]..[AWS_Documentos] awsd ON otpas.AWSDocumentoId = awsd.AWSDocumentoId
        WHERE otpas.IdOTSolicitudMaterial = @IdOTSolicitudMaterial--1
              AND ((FechaInicioSemana = @fechaIni
                    AND FechaFinSemana = @fechaFin)
                   OR (@fechaIni IS NULL
                       AND @fechaFin IS NULL));
    END;