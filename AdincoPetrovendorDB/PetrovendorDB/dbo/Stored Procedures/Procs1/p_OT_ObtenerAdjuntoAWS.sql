--	p_OT_ObtenerAdjuntoAWS 1
CREATE PROC p_OT_ObtenerAdjuntoAWS(@IdOT INT)
AS
    BEGIN
        SELECT awsd.Bucket, 
               awsd.Folder, 
               awsd.UUIDAmazon, 
               awsd.NombreArchivo, 
               awsd.Meta
        FROM [Adinco]..[OT_ProgramaAdjuntoSemana] otpas
             INNER JOIN [Adinco]..OT_SolicitudMaterial om ON om.IdOTSolicitudMaterial = otpas.IdOTSolicitudMaterial
             INNER JOIN [Adinco]..[AWS_Documentos] awsd ON otpas.AWSDocumentoId = awsd.AWSDocumentoId
        WHERE om.IdOTSolicitud = @IdOT
        UNION
        SELECT awsd.Bucket, 
               awsd.Folder, 
               awsd.UUIDAmazon, 
               awsd.NombreArchivo, 
               awsd.Meta
        FROM [Adinco]..[OT_ProgramaAdjunto] otpas
             INNER JOIN [Adinco]..[AWS_Documentos] awsd ON otpas.AWSDocumentoId = awsd.AWSDocumentoId
        WHERE otpas.IdOTSolicitud = @IdOT;
    END;