DROP PROCEDURE IF EXISTS MM_SP_DescargarDocumentoSolPed
GO
-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <17-09-2018>
-- Description:	<Se agrega el bit de activo>
-- =============================================
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <02-03-2018>
-- Description:	<Descarga de un documento adjunto en la SolPed> 
-- Update S3 DANIEL AC 27/04/2018 para consulta de indicadores de documentos en s3
-- =============================================
-- Author:		LUIS DAVID
-- Create date: 21/09/2021
-- Description:	SE AGREGA EL BUCKET A LA CONSULTA
-- =============================================
CREATE PROCEDURE [dbo].[MM_SP_DescargarDocumentoSolPed] @IdDocumento INT ,
														/*--------------------parametros contrato  --------------------*/
														@IdContrato INT = NULL, @IdUsuario INT = NULL ,
														@FechaRegistro DATETIME = NULL
/*-------------------------------------------------------------*/
AS
	BEGIN
		SELECT	'' AS ArchivoAdjuntoMaterial, NombreArchivoAdjunto, Carpeta, Identificador, Extension, Mime, ISNULL(Bucket,'') as Bucket
		FROM	dbo.MM_SolPedArchivoAdjuntoMaterial
		WHERE
				IdSolPedMaterialDocumentoAdj = @IdDocumento
				AND Activo = 1
	END
