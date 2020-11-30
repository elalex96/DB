
CREATE PROCEDURE [dbo].[SP_MM_ConsultarFechaFinalizacionCotizacion] 
	@IdSolicitudPedido INT,
	@IdProveedor int
AS
BEGIN

DECLARE @CANTIDAD_PEDIDO INT 
  SET @CANTIDAD_PEDIDO =( SELECT COUNT(P.IdPedido)
   FROM dbo.TA_Operacion AS O
   INNER JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = O.IdDocumento
   INNER JOIN dbo.MM_SolicitudPedidoDetalle AS SPD ON SPD.IdSolicitudPedido = SP.IdSolicitudPedido
   INNER JOIN dbo.MM_Pedido  AS P ON P.IdSolicitudPedido= SP.IdSolicitudPedido 
   INNER JOIN dbo.MM_PedidoDetalle AS PD ON PD.IdPedido = P.IdPedido
   INNER JOIN dbo.MM_PeticionOferta AS PO ON PO.IdPeticionOferta= P.IdPeticionOferta
   INNER JOIN dbo.MM_PeticionOfertaDetalle AS POD ON POD.IdPeticionOfertaDetalle=PD.IdPeticionOfertaDetalle
   WHERE 
   SPD.IdSolicitudPedidoDetalle= POD.IdSolicitudPedidoDetalle
   AND SP.IdSolicitudPedido= PO.IdSolicitudPedido
   AND SP.IdSolicitudPedido = @IdSolicitudPedido 
   AND ISNULL(P.IdEstatusEliminado,0)<>1
   AND O.IdEstatusOperacion <> 3--DESCARTA LOS PEDIDOS RECHAZADOS
   AND O.IdTipoOperacion= 9)

   SELECT O.FechaFinalizacion, ISNULL(@CANTIDAD_PEDIDO,0) AS NoPedidos
   FROM dbo.TA_Operacion AS O
   INNER JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = O.IdDocumento
   WHERE SP.IdSolicitudPedido = @IdSolicitudPedido
    AND O.IdTipoOperacion= 6 
	AND O.IdProveedor = @IdProveedor


   ---#IdTipoOperacion 6 Peticiones de oferta o cotizaciones 
    
END
