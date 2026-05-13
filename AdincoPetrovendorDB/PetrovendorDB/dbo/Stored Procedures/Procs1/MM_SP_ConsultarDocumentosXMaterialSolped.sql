USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'MM_SP_ConsultarDocumentosXMaterialSolped'
)
    DROP PROCEDURE MM_SP_ConsultarDocumentosXMaterialSolped;
/****** Object:  StoredProcedure [dbo].[MM_SP_ConsultarDocumentosXMaterialSolped]    Script Date: 28/08/2023 03:57:11 p. m. ******/
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
-- Author:		Daniel AC
-- Create date: <28-08-2023>
-- Description:	Se elimina comentarios 
-- =============================================
CREATE PROCEDURE [dbo].[MM_SP_ConsultarDocumentosXMaterialSolped] 
@IdSolicitudPedidoDetalle INT ,
@IdContrato INT = NULL, @IdUsuario INT = NULL ,
@FechaRegistro DATETIME = NULL

AS
	BEGIN	
					
		SELECT	IdSolPedMaterialDocumentoAdj, NombreArchivoAdjunto
		FROM	MM_SolPedArchivoAdjuntoMaterial (NOLOCK)
		WHERE
				IdSolPedDetalle = @IdSolicitudPedidoDetalle
				AND Activo = 1 --> QUE EL DOCUMENTO ESTE ACTIVO
	END