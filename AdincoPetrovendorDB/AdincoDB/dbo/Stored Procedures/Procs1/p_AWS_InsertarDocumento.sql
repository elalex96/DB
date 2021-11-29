CREATE PROC p_AWS_InsertarDocumento
(@pAWSDocumentoId      INT OUT, 
 @pNombreArchivo       VARCHAR(250), 
 @pFolder              VARCHAR(100), 
 @pUUIDAmazon          UNIQUEIDENTIFIER, 
 @pMeta                VARCHAR(200), 
 @pBucket              VARCHAR(50), 
 @pCreadoPor           INT, 
 @pAWSDocumentoPadreId INT, 
 @pHashSHA256          VARCHAR(1000), 
 @pPeso                INT              = 0
)
AS
     BEGIN
         SELECT @pAWSDocumentoId = isnull(MAX(AWSDocumentoId), 0) + 1
         FROM [AWS_Documentos];
         INSERT INTO [AWS_Documentos]
         (AWSDocumentoId, 
          NombreArchivo, 
          UUIDAmazon, 
          Meta, 
          Bucket, 
          CreadoPor, 
          CreadoEl, 
          ModificadoPor, 
          ModificadoEl, 
          Folder, 
          HashSHA256

         /*,		Peso*/

         )
                SELECT @pAWSDocumentoId, 
                       @pNombreArchivo, 
                       @pUUIDAmazon, 
                       @pMeta, 
                       @pBucket, 
                       @pCreadoPor, 
                       GETDATE(), 
                       NULL, 
                       NULL, 
                       @pFolder, 
                       @pHashSHA256;--,	@pPeso

         IF(isnull(@pAWSDocumentoPadreId, 0) > 0)
             BEGIN
                 INSERT INTO [dbo].[AWS_DocumentosRelacion]
                        SELECT @pAWSDocumentoPadreId, 
                               @pAWSDocumentoId, 
                               GETDATE(), 
                               @pCreadoPor, 
                               NULL, 
                               NULL;
             END;
     END;


