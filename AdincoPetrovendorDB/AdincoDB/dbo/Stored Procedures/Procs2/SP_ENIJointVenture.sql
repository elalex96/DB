-- =============================================
-- Author:		Manuel Cruz
-- Create date: 26-06-2020
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_ENIJointVenture]
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@IdUsuario  INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         SELECT A.IdAWSDocumento, 
                C.NumeroContrato AS Contrato, 
                A.NombreArchivo, 
                U.Nombre AS CreadoPor, 
                A.CreadoEl
         FROM dbo.AWS_DocumentoENI A
              JOIN dbo.CO_Contrato C ON C.IdContrato = A.IdContrato
              JOIN dbo.AP_Usuario U ON A.CreadoPor = U.UsuarioID
         WHERE A.Folder = 'ENIArchivos/JOINTVENTURE/'
               AND ISNULL(A.Privado, 0) = 0
               AND A.IdContrato = @IdContrato
         ORDER BY A.CreadoEl DESC;
     END;