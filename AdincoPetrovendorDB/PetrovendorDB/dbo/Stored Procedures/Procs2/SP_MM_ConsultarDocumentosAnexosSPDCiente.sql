-- =============================================
-- Author:	Daniel AC
-- Create date: <25/08/2022>
-- Description:	Optimización de sp
-- =============================================

CREATE PROCEDURE [dbo].[SP_MM_ConsultarDocumentosAnexosSPDCiente]
	@IdPeticionOferta INT,
	@IdPeticionOfertaDetalle int
AS
BEGIN

	SELECT IdSolPedMaterialDocumentoAdj AS IdDocumentoAnexo ,
	NombreArchivoAdjunto AS Nombre
	FROM MM_PeticionOfertaDetalle AS POD (NOLOCK)
	JOIN MM_SolicitudPedidoDetalle AS SPD (NOLOCK)	
		ON  POD.IdSolicitudPedidoDetalle  = SPD.IdSolicitudPedidoDetalle 
		AND POD.IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle
	JOIN MM_SolPedArchivoAdjuntoMaterial AS SPDAD (NOLOCK)
		ON SPD.IdSolicitudPedidoDetalle	 = SPDAD.IdSolPedDetalle 
	WHERE POD.IdPeticionOferta = @IdPeticionOferta		
	AND SPDAD.Activo = 1

END

