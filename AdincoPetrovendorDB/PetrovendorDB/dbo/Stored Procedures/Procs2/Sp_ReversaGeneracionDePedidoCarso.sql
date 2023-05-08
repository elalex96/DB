CREATE PROCEDURE Sp_ReversaGeneracionDePedidoCarso
(@IdPedido                INT, 
 @IdSolicitudPedido       INT, 
 @Version                 INT, 
 @CantidadTemp            FLOAT, 
 @IdPeticionOfertaDetalle INT
)
AS
    BEGIN
        DECLARE @PrecioUnitario MONEY;
        UPDATE dbo.MM_Pedido
          SET 
              IdEstatusEliminado = 1
        WHERE IdPedido = @IdPedido;
        UPDATE dbo.MM_PedidoDetalle
          SET 
              IdEstatusEliminado = 1
        WHERE IdPedido = @IdPedido;
        UPDATE dbo.TA_Operacion
          SET 
              IdEstatusEliminado = 1
        WHERE IdDocumento = @IdSolicitudPedido
              AND NoVersion = @Version;
        SELECT @PrecioUnitario = PrecioUnitario
        FROM dbo.MM_PeticionOfertaDetalle
        WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle;
        UPDATE pod
          SET 
              pod.AddPedidoTemp = 1, 
              pod.AddCantidadTemp = @CantidadTemp, 
              pod.AddSubTotalTemp = ISNULL(@PrecioUnitario, 0) * @CantidadTemp, 
              pod.AddValidado = 1
        FROM dbo.MM_PeticionOfertaDetalle pod
        WHERE pod.IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle;
    END;