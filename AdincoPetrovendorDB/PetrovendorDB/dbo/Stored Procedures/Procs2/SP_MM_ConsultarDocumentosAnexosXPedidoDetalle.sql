CREATE PROCEDURE [dbo].[SP_MM_ConsultarDocumentosAnexosXPedidoDetalle]
	@IdPedido INT,
	@IdPedidoDetalle int
AS
BEGIN

	SELECT IdDocumentoAnexo, Nombre
		FROM dbo.MM_DocumentosAnexos
		WHERE IdPeticionOferta = @IdPedido
			AND IdPeticionOfertaDetalle = @IdPedidoDetalle
			AND Activo=1

END