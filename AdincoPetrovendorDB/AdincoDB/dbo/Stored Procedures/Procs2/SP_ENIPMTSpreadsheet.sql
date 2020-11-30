-- =============================================
-- Author:		Manuel Cruz
-- Create date: 26-06-2020
-- Description:	
-- =============================================
CREATE PROCEDURE SP_ENIPMTSpreadsheet
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@IdUsuario  INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         SELECT TOP 1 A.IdAWSDocumento, 
                      A.NombreArchivo, 
                      A.Bucket, 
                      A.Folder, 
                      UPPER(A.UUIDAmazon) AS UUIDAmazon, 
                      LTRIM(RTRIM(SUBSTRING(A.NombreArchivo, CHARINDEX('.', A.NombreArchivo, LEN(A.NombreArchivo)-5), LEN(A.NombreArchivo)))) AS TipoArchivo
         FROM dbo.AWS_DocumentoENI A
              JOIN dbo.CO_Contrato C ON C.IdContrato = A.IdContrato
              JOIN dbo.AP_Usuario U ON A.CreadoPor = U.UsuarioID
         WHERE A.Folder = 'ENIArchivos/PMT/'
               AND A.IdContrato = @IdContrato --3
         ORDER BY A.CreadoEl DESC;
     END;
