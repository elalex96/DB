-- =============================================
-- Author:		Manuel Cruz
-- Create date: 2018-12-12
-- Description:	
-- =============================================
CREATE PROCEDURE SP_AWS_ReemplazarCCN 
-- SP_AWS_ReemplazarCCN 3,1,61498,0
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@IdUsuario  INT, 
@IdDoc      INT, 
@IdEliminar INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         DECLARE @Count INT; 
         --
         SELECT @Count = COUNT(IdDocAdinco)
         FROM dbo.AWS_DocAwsDocAdinco
         WHERE IdDocAdinco = @IdDoc;
         --SELECT @Count
         --
         IF(@Count > 0
            AND @IdEliminar = 0)
             BEGIN
                 SELECT 'true' AS Existe, 
                        D.UUIDAmazon AS UUID, 
                        D.AWSDocumentoId AS AWSDocumentoId, 
                        D.Folder AS Folder
                 FROM dbo.AWS_DocAwsDocAdinco AA
                      JOIN dbo.AWS_Documentos D ON D.AWSDocumentoId = AA.AWSDocumentoId
                 WHERE IdDocAdinco = @IdDoc;
             END;
         IF(@Count = 0
            AND @IdEliminar = 0)
             BEGIN
                 SELECT 'false' AS Existe, 
                        '' AS UUID, 
                        0 AS AWSDocumentoId, 
                        '' AS Folder;
             END;
         IF(@Count > 0
            AND @IdEliminar <> 0)
             BEGIN
                 DELETE dbo.AWS_DocAwsDocAdinco
                 WHERE IdDocAdinco = @IdDoc;
                 DELETE dbo.AWS_Documentos
                 WHERE AWSDocumentoId = @IdEliminar;
                 SELECT 'delete' AS Existe, 
                        '' AS UUID, 
                        0 AS AWSDocumentoId, 
                        '' AS Folder;
             END;
     END;
