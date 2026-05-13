-- =============================================
-- Author:		Manuel Cruz
-- Create date: 26/07/17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ViewPdfTransfer] 
-- Add the parameters for the stored procedure here
@IdTran INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         SELECT T.IdTransferencia, 
                T.PDF, 
                AWSPDFId = isnull(AWSPDFId, 0), 
                aws.Bucket, 
                aws.Folder, 
                aws.UUIDAmazon, 
                aws.NombreArchivo, 
                aws.Meta
         FROM FI_Transfer T (NOLOCK)
              LEFT JOIN AWS_Documentos aws (NOLOCK) ON aws.AWSDocumentoId = t.AWSPDFId
         WHERE T.IdTransferencia = @IdTran;

         --exec SP_FI_ViewPdfTransfer 650
     END;