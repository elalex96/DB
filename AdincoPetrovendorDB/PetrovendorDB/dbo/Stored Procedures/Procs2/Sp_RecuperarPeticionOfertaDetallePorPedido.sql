CREATE PROCEDURE Sp_RecuperarPeticionOfertaDetallePorPedido
(
    @IdPedido INT,
    @IdProveedor INT
)
AS
BEGIN

    SELECT p.IdPedido,
           p.IdPeticionOferta,
           p.Version,
           p.IdSolicitudPedido,
		   pod.IdPeticionOfertaDetalle,
		   ps.IdPedido AS IdPedidoGral
    FROM dbo.MM_Pedidos ps
        INNER JOIN dbo.MM_Pedido p
            ON ps.IdIdentificador = p.IdPedido
        INNER JOIN dbo.MM_PeticionOfertaDetalle pod
            ON pod.IdPeticionOferta = p.IdPeticionOferta
    WHERE p.IdPedido = @IdPedido
          AND ps.IdProveedorCliente = @IdProveedor

	
END