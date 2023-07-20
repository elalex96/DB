USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'MM_SP_DescargarDocSolPed'
)
    DROP PROCEDURE MM_SP_DescargarDocSolPed;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <02-03-2018>
-- Description:	<Descarga de un documento adjunto en la SolPed>
-- Update: Daniel AC se agrego parametros para consulta de documentos en S3
-- =============================================
-- Author:		LUIS DAVID
-- Create date: <21/09/2021>
-- Description:	SE AGREGA EL BUCKET A LA CONSULTA
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <19-07-2023>
-- Description:	aplicacion de optimizaciones y estandares de desarrollo issue:https://github.com/Adinco/petrovendor/issues/2379
-- =============================================

CREATE PROCEDURE [dbo].[MM_SP_DescargarDocSolPed]
@IdDocumento INT,
/*--------------------parametros contrato  --------------------*/
@IdContrato INT = NULL,
@IdUsuario INT = NULL,
@FechaRegistro DATETIME = NULL
/*-------------------------------------------------------------*/
AS
BEGIN
    SELECT '' AS Documento,
           NombreDoc,
           Carpeta,
           Identificador,
           Extension,
           Mime, 
		   Isnull(Bucket,'') as Bucket
    FROM dbo.MM_DocumentosSolPed (NOLOCK)
    WHERE IdDocumento = @IdDocumento
    UNION
    SELECT '' AS ArchivoAdjuntoMaterial,
           NombreArchivoAdjunto,
           Carpeta,
           Identificador,
           Extension,
           Mime,
		   Isnull(Bucket,'') as Bucket
    FROM dbo.MM_SolPedArchivoAdjuntoMaterial (NOLOCK)
    WHERE IdSolPedMaterialDocumentoAdj = @IdDocumento
          AND Activo = 1
END
