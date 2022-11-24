-- =============================================
-- Author:	Daniel AC
-- Create date: <25/08/2022>
-- Description:	Optimización de sp
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarDocumentosAnexosXPedidoDetalle]
	@IdPedido INT,
	@IdPedidoDetalle int
AS
BEGIN

	SELECT IdDocumentoAnexo, Nombre
	FROM MM_DocumentosAnexos (NOLOCK)
	WHERE IdPeticionOferta = @IdPedido
	AND IdPeticionOfertaDetalle = @IdPedidoDetalle
	AND Activo=1

END