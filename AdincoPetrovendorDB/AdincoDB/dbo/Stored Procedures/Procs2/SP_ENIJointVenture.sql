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
CREATE PROCEDURE [dbo].[SP_ENIJointVenture] --3,1000,1,''
-- Add the parameters for the stored procedure here
	@IdContrato INT, 
	@IdUsuario  INT,
	@Page INT,
	@Buscar NVARCHAR(MAX)
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

	DECLARE @AllRecords INT;
	DECLARE @RecordsByPage INT = 10;

         -- Insert statements for procedure here
		 SET @AllRecords = (SELECT COUNT(1)
         FROM dbo.AWS_DocumentoENI A
              JOIN dbo.CO_Contrato C ON C.IdContrato = A.IdContrato
              JOIN dbo.AP_Usuario U ON A.CreadoPor = U.UsuarioID
		 WHERE A.Privado = 0
		 AND A.Folder = 'ENIArchivos/JOINTVENTURE/');

		 SELECT *,
			  @AllRecords AS Records,
			  @RecordsByPage AS RecordsByPage
		FROM
		(
		 SELECT 
				ROW_NUMBER() OVER(PARTITION BY A.IdAWSDocumento ORDER BY A.IdAWSDocumento DESC) AS R,
				A.Folder,
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
				UUIDAmazon,
				A.Meta,
				(ROW_NUMBER() OVER(ORDER BY A.CreadoEl DESC) - 1) / @RecordsByPage AS _Page
         FROM dbo.AWS_DocumentoENI A
              JOIN dbo.CO_Contrato C ON C.IdContrato = A.IdContrato
              JOIN dbo.AP_Usuario U ON A.CreadoPor = U.UsuarioID
		 WHERE A.Privado = 0
		 AND A.Folder = 'ENIArchivos/JOINTVENTURE/'
		 AND (C.NumeroContrato LIKE '%' + @Buscar + '%'
				OR NombreArchivo LIKE '%' + @Buscar + '%')) AS R
		 WHERE R.R = 1 AND R._PAGE = (@Page - 1)
		 ORDER BY R.CreadoEl DESC;

     END;