-- =============================================
-- Author:		Manuel Cruz
-- Create date: 26-06-2020
-- Description:	
-- =============================================
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 18/06/2021
-- Description:	agregado de indicadores de tipo de archivos
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
		 SELECT A.Folder,
				A.IdAWSDocumento, 
				C.NumeroContrato AS Contrato,
                CASE
                    WHEN A.Folder = 'ENIArchivos/PMT/'
                    THEN 'PMT'
                    WHEN A.Folder = 'ENIArchivos/JOINTVENTURE/'
                    THEN 'JOINT VENTURE'
					WHEN A.Folder = 'ENIArchivos/PLANESAPROBADOS/'
                    THEN 'Planes Aprobados'
					when A.Folder = 'ENIArchivos/PROGRAMAMÍNIMODETRABAJO/'
					then 'Programa Mínimo de Trabajo'
                END AS Tipo, 
                NombreArchivo, 
                U.Nombre AS CreadoPor, 
                A.CreadoEl,
                CASE
                    WHEN ISNULL(A.Privado, 0) = 0
                    THEN 'Público'
                    WHEN ISNULL(A.Privado, 0) = 1
                    THEN 'Privado'
                END AS Clasificacion,
				UUIDAmazon
         FROM dbo.AWS_DocumentoENI A
              JOIN dbo.CO_Contrato C ON C.IdContrato = A.IdContrato
              JOIN dbo.AP_Usuario U ON A.CreadoPor = U.UsuarioID
		 WHERE A.Privado = 0
		 AND A.Folder = 'ENIArchivos/JOINTVENTURE/'
         ORDER BY A.CreadoEl DESC;

         --SELECT A.IdAWSDocumento, 
         --       C.NumeroContrato AS Contrato, 
         --       A.NombreArchivo, 
         --       U.Nombre AS CreadoPor, 
         --       A.CreadoEl
         --FROM dbo.AWS_DocumentoENI A
         --     JOIN dbo.CO_Contrato C ON C.IdContrato = A.IdContrato
         --     JOIN dbo.AP_Usuario U ON A.CreadoPor = U.UsuarioID
         --WHERE A.Folder = 'ENIArchivos/JOINTVENTURE/'
         --      AND ISNULL(A.Privado, 0) = 0
         --      AND A.IdContrato = @IdContrato
         --ORDER BY A.CreadoEl DESC;
     END;