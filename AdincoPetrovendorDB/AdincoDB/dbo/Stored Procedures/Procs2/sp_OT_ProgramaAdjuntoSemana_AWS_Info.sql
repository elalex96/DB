CREATE PROC sp_OT_ProgramaAdjuntoSemana_AWS_Info(@pAWSDocumentoId INT)
AS
    BEGIN
        SELECT Bucket, 
               d.Folder, 
               UUIDAmazon--, *
        FROM OT_ProgramaAdjuntoSemana pas
             INNER JOIN AWS_Documentos d ON d.AWSDocumentoId = pas.AWSDocumentoId
        WHERE pas.ID = @pAWSDocumentoId;--301

    END;
