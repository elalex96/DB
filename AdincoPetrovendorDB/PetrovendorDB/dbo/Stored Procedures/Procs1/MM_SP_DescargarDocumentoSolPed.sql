USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'MM_SP_DescargarDocumentoSolPed'
)
    DROP PROCEDURE MM_SP_DescargarDocumentoSolPed;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
-- Author:		<Alexander Gomez>
-- Create date: <19-07-2023>
-- Description:	aplicacion de optimizaciones y estandares de desarrollo issue:https://github.com/Adinco/petrovendor/issues/2379
-- =============================================
CREATE PROCEDURE [dbo].[MM_SP_DescargarDocumentoSolPed] @IdDocumento INT ,
														/*--------------------parametros contrato  --------------------*/
														@IdContrato INT = NULL, @IdUsuario INT = NULL ,
														@FechaRegistro DATETIME = NULL
/*-------------------------------------------------------------*/
AS
	BEGIN
		SELECT	'' AS ArchivoAdjuntoMaterial, NombreArchivoAdjunto, Carpeta, Identificador, Extension, Mime, ISNULL(Bucket,'') as Bucket
		FROM	dbo.MM_SolPedArchivoAdjuntoMaterial (NOLOCK)
		WHERE
				IdSolPedMaterialDocumentoAdj = @IdDocumento
				AND Activo = 1
	END