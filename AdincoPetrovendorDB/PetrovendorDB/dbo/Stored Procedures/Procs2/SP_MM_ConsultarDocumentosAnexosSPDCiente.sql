-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <17-09-2018>
-- Description:	<Se agrega el bit de activo>
-- =============================================

CREATE PROCEDURE [dbo].[SP_MM_ConsultarDocumentosAnexosSPDCiente]
	@IdPeticionOferta INT,
	@IdPeticionOfertaDetalle int
AS
BEGIN

	SELECT [IdSolPedMaterialDocumentoAdj] AS IdDocumentoAnexo ,[NombreArchivoAdjunto] AS Nombre
		FROM MM_SolPedArchivoAdjuntoMaterial AS SPDAD
		INNER JOIN MM_SolicitudPedidoDetalle AS SPD ON SPD.IdSolicitudPedidoDetalle= SPDAD.IdSolPedDetalle
		INNER JOIN MM_PeticionOfertaDetalle AS POD ON POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
		WHERE IdPeticionOferta = @IdPeticionOferta
			AND IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle
			AND SPDAD.Activo = 1

END

