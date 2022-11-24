-- =============================================
-- Author:		Manuel Cruz
-- Create date: 23-06-2020
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_AWSDocumentoENIGuardar]
-- Add the parameters for the stored procedure here
@s3Bucket    VARCHAR(500), 
@subcarpeta  VARCHAR(500), 
@uuid        VARCHAR(500), 
@newFileName VARCHAR(500), 
@contentType VARCHAR(500), 
@IdContrato  INT, 
@IdUsuario   INT, 
@Privado     BIT = NULL
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

		 IF @subcarpeta = 'ENIArchivos/PROGRAMAMÍNIMODETRABAJO/'
		 BEGIN
			SET @Privado = 0;
		 END

         -- Insert statements for procedure here
         INSERT INTO dbo.AWS_DocumentoENI
         (Bucket, 
          Folder, 
          UUIDAmazon, 
          NombreArchivo, 
          Meta, 
          IdContrato, 
          CreadoPor, 
          CreadoEl, 
          Privado
         )
         VALUES
         (@s3Bucket, 
          @subcarpeta, 
          @uuid, 
          @newFileName, 
          @contentType, 
          @IdContrato, 
          @IdUsuario, 
          GETDATE(), 
          @Privado
         );
         IF @@ERROR <> 0
             BEGIN
                 SELECT 'false' AS msj;
             END;
             ELSE
             BEGIN
                 SELECT 'true' AS msj
             END;
     END;