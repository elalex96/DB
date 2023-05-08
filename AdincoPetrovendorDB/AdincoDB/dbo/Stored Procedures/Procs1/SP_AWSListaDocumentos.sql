-- =============================================
-- Author:		Manuel Cruz
-- Create date: 25-06-2020
-- Description:	
-- =============================================
CREATE PROCEDURE SP_AWSListaDocumentos
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@IdUsuario  INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         SELECT Bucket, 
                Folder, 
                UUIDAmazon, 
                NombreArchivo, 
                Meta, 
                CONCAT(Folder, '/', UUIDAmazon) AS Ruta
         FROM AWS_DocumentoENI
         WHERE IdContrato = @IdContrato;
     END;
