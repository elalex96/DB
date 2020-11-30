-- =============================================
-- Author:		Manuel Cruz
-- Create date: 2018-12-11
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_AWS_GuardaCCNFactura]
-- Add the parameters for the stored procedure here
@IdContrato     INT, 
@IdUsuario      INT, 
@IdDoc          INT, 
@TipoDoc        INT, 
@AWSDocumentoId INT, 
@Bucket         NVARCHAR(50), 
@Folder         NVARCHAR(100), 
@UUIDAmazon     UNIQUEIDENTIFIER, 
@NombreArchivo  NVARCHAR(250), 
@Meta           NVARCHAR(50)
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         SELECT @AWSDocumentoId = ISNULL(MAX(AWSDocumentoId), 0) + 1
         FROM [AWS_Documentos];

         /**/

         INSERT INTO [dbo].[AWS_Documentos]
         ([AWSDocumentoId], 
          [Bucket], 
          [Folder], 
          [UUIDAmazon], 
          [NombreArchivo], 
          [Meta], 
          [CreadoPor], 
          [CreadoEl]
         )
         VALUES
         (@AWSDocumentoId, 
          @Bucket, 
          @Folder, 
          @UUIDAmazon, 
          @NombreArchivo, 
          @Meta, 
          @IdUsuario, 
          GETDATE()
         );
         IF(ISNULL(@AWSDocumentoId, 0) > 0)
             BEGIN
                 INSERT INTO [dbo].[AWS_DocAwsDocAdinco]
                 ([AWSDocumentoId], 
                  [IdDocAdinco], 
                  [IdTipoDocumento], 
                  [IdContrato], 
                  [CreadoPor], 
                  [CreadoEn]
                 )
                 VALUES
                 (@AWSDocumentoId, 
                  @IdDoc, 
                  @TipoDoc, 
                  @IdContrato, 
                  @IdUsuario, 
                  GETDATE()
                 );
             END;
         --
         IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj;
     END;
