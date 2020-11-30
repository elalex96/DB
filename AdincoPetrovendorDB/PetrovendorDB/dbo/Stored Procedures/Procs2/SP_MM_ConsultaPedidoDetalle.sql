CREATE PROCEDURE [dbo].[SP_MM_ConsultaPedidoDetalle]
    @IdProveedor INT,
    @IdPedido INT
AS
BEGIN
    SELECT PD.RecepcionPedido,
           PD.IdPedidoDetalle,
           PD.IdMaterialVendedor,
           M.DescripcionCorta
    FROM MM_PedidoDetalle AS PD
        INNER JOIN MM_Pedido AS P
            ON P.IdPedido = PD.IdPedido
        INNER JOIN MM_Material AS M
            ON M.IdMaterial = PD.IdMaterialVendedor
    WHERE P.IdPedido = @IdPedido
          AND P.IdProveedorCompras = @IdProveedor
          AND P.RecepcionServicio = 1

END