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
CREATE PROCEDURE [dbo].[SP_ENIJointVentureDescargaVisor]
-- Add the parameters for the stored procedure here
@IdContrato     INT, 
@IdUsuario      INT, 
@IdAWSDocumento INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         SELECT A.IdAWSDocumento, 
                A.NombreArchivo, 
                A.Bucket, 
                A.Folder, 
                UPPER(A.UUIDAmazon) AS UUIDAmazon, 
                LTRIM(RTRIM(SUBSTRING(A.NombreArchivo, CHARINDEX('.', A.NombreArchivo, LEN(A.NombreArchivo)-5), LEN(A.NombreArchivo)))) AS TipoArchivo,
				Meta,
				CASE
                    WHEN A.Folder = 'ENIArchivos/PMT/'
                    THEN 'PMT'
                    WHEN A.Folder = 'ENIArchivos/JOINTVENTURE/'
                    THEN 'JOINT VENTURE'
					WHEN A.Folder = 'ENIArchivos/PLANESAPROBADOS/'
                    THEN 'Planes Aprobados'
					when A.Folder = 'ENIArchivos/PROGRAMAMÍNIMODETRABAJO/'
					then 'Programa Mínimo de Trabajo'
                END AS Tipo
         FROM dbo.AWS_DocumentoENI A
              JOIN dbo.CO_Contrato C ON C.IdContrato = A.IdContrato
              JOIN dbo.AP_Usuario U ON A.CreadoPor = U.UsuarioID
         WHERE A.IdAWSDocumento = @IdAWSDocumento
         ORDER BY A.CreadoEl DESC;
     END;