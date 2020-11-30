-- p_AWS_ObtenerArchivo 1
CREATE PROC [dbo].[p_AWS_ObtenerArchivo] @pAWSDocumentoId INT OUT
AS
     SELECT doc.AWSDocumentoId, 
            doc.Bucket,
            CASE
                WHEN CHARINDEX('/', doc.Folder) > 0
                THEN doc.Folder
                ELSE doc.Folder+'/'
            END AS Folder, 
            UPPER(doc.UUIDAmazon) AS UUIDAmazon, 
            T.NombreExtencionArchivo AS NombreArchivo, 
            doc.Meta, 
            doc.CreadoPor, 
            doc.CreadoEl, 
            doc.ModificadoPor, 
            doc.ModificadoEl
     FROM [AWS_Documentos] doc
          JOIN dbo.FI_Transfer T ON doc.AWSDocumentoId = t.AWSPDFId
     WHERE AWSDocumentoId = @pAWSDocumentoId;