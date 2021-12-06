USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[MM_SP_ConsultarDocumentosXMaterialSolped]    Script Date: 26/11/2021 01:38:52 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <>
-- Description:	<>
-- =============================================
-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <17-09-2018>
-- Description:	<Se agrega el bit de activo>
-- =============================================
ALTER PROCEDURE [dbo].[MM_SP_ConsultarDocumentosXMaterialSolped] @IdSolicitudPedidoDetalle INT ,
															/*--------------------parametros contrato  --------------------*/
														  @IdContrato INT = NULL, @IdUsuario INT = NULL ,
														  @FechaRegistro DATETIME = NULL
/*-------------------------------------------------------------*/
AS
	BEGIN
	SELECT TOP 1	IdSolPedMaterialDocumentoAdj, NombreArchivoAdjunto
		FROM	MM_SolPedArchivoAdjuntoMaterial (NOLOCK)
		WHERE
				IdSolPedDetalle = @IdSolicitudPedidoDetalle
				AND Activo = 0


				/***Optimizacion*/
		--SELECT	IdSolPedMaterialDocumentoAdj, NombreArchivoAdjunto
		--FROM	MM_SolPedArchivoAdjuntoMaterial
		--WHERE
		--		IdSolPedDetalle = @IdSolicitudPedidoDetalle
		--		AND Activo = 1
	END
