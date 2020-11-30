-- =============================================
-- Author:		Manuel Cruz
-- Create date: 26-06-2020
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_ENIArchivosCargados] 
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@IdUsuario  INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         SELECT C.NumeroContrato AS Contrato,
                CASE
                    WHEN A.Folder LIKE 'ENIArchivos/PMT/'
                    THEN 'PMT'
                    WHEN A.Folder LIKE 'ENIArchivos/JOINTVENTURE/'
                    THEN 'JOINT VENTURE'
                END AS Tipo, 
                NombreArchivo, 
                U.Nombre AS CreadoPor, 
                A.CreadoEl,
                CASE
                    WHEN ISNULL(A.Privado, 0) = 0
                    THEN 'Público'
                    WHEN ISNULL(A.Privado, 0) = 1
                    THEN 'Privado'
                END AS Clasificacion
         FROM dbo.AWS_DocumentoENI A
              JOIN dbo.CO_Contrato C ON C.IdContrato = A.IdContrato
              JOIN dbo.AP_Usuario U ON A.CreadoPor = U.UsuarioID
         ORDER BY A.CreadoEl DESC;
     END;