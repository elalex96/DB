-- ============================================= 
-- Author:		Daniel AC
-- Create date: 18/10/2017
-- Description:	Validar unidades disponibles para agregar a la orden de compra  
-- =============================================
-- ============================================= 
-- Author:		Daniel AC
-- Create date: 04/06/2018
-- Description: Descartar cantidades de pedidos detalle que han sido eliminados (estatuseliminacion=1)
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarDisponibilidadPOD]  ---13725, 5342,NULL
    -- Add the parameters for the stored procedure here

    @IdPeticionOfertaDetalle INT,
	@IdSolicitudPedidoDetalle INT,
	@CM_DISPONIBILIDAD_FINAL FLOAT OUTPUT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    DECLARE @IdTipoOperacion INT = 9; --IdTipoOperacion = 9 Aprobación de pedido 
    DECLARE @CM_DISPONIBILIDAD FLOAT;
    DECLARE @CM_PEDIDO_EN_APROBACION FLOAT;
    DECLARE @CM_PEDIDO_APROBADO_EN_RECEPCION FLOAT;
    DECLARE @CM_PEDIDO_APROBADO_EN_RECEPCION_CONFIRMADA FLOAT;
    


    SET @CM_DISPONIBILIDAD =
    (
        SELECT Disponibilidad
        FROM dbo.MM_PeticionOfertaDetalle
        WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle
    );
    SET @CM_PEDIDO_EN_APROBACION =
    (
        SELECT ISNULL(SUM(PD.Cantidad), 0)
        FROM dbo.MM_PedidoDetalle AS PD
            INNER JOIN dbo.MM_Pedido AS P
                ON P.IdPedido = PD.IdPedido
            INNER JOIN dbo.MM_PeticionOferta AS PO
                ON PO.IdPeticionOferta = P.IdPeticionOferta
            INNER JOIN dbo.MM_PeticionOfertaDetalle AS POD
                ON POD.IdPeticionOferta = PO.IdPeticionOferta
            INNER JOIN dbo.MM_SolicitudPedido AS SP
                ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
            INNER JOIN dbo.MM_SolicitudPedidoDetalle AS SPD
                ON SPD.IdSolicitudPedido = SP.IdSolicitudPedido
            INNER JOIN dbo.TA_Operacion AS O
                ON O.IdDocumento = SP.IdSolicitudPedido
        WHERE SPD.IdSolicitudPedidoDetalle = @IdSolicitudPedidoDetalle
              AND POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
              AND PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
              AND P.Version = O.NoVersion
              AND O.IdTipoOperacion = @IdTipoOperacion
              AND POD.IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle
              AND O.IdEstatusOperacion = 1
			  AND ISNULL(P.IdEstatusEliminado,0)<>1  --> PEDIDO SEA DIFERENTE DE ELIMINADO
    );


    SET @CM_PEDIDO_APROBADO_EN_RECEPCION =
    (
        SELECT ISNULL(SUM(PD.Cantidad), 0)
        FROM dbo.MM_PedidoDetalle AS PD
            INNER JOIN dbo.MM_Pedido AS P
                ON P.IdPedido = PD.IdPedido
            INNER JOIN dbo.MM_PeticionOferta AS PO
                ON PO.IdPeticionOferta = P.IdPeticionOferta
            INNER JOIN dbo.MM_PeticionOfertaDetalle AS POD
                ON POD.IdPeticionOferta = PO.IdPeticionOferta
            INNER JOIN dbo.MM_SolicitudPedido AS SP
                ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
            INNER JOIN dbo.MM_SolicitudPedidoDetalle AS SPD
                ON SPD.IdSolicitudPedido = SP.IdSolicitudPedido
            INNER JOIN dbo.TA_Operacion AS O
                ON O.IdDocumento = SP.IdSolicitudPedido
            INNER JOIN [dbo].[MM_HorasVigenciaPedido] AS PHV
                ON PHV.IdPedido = P.IdPedido
        WHERE SPD.IdSolicitudPedidoDetalle = @IdSolicitudPedidoDetalle
              AND POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
              AND PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
              AND P.Version = O.NoVersion
              AND O.IdTipoOperacion = @IdTipoOperacion
              AND POD.IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle
              AND O.IdEstatusOperacion = 2
              AND PHV.FechaVigencia > GETDATE()
              AND P.RecepcionServicio IS NULL
			  AND ISNULL(P.IdEstatusEliminado,0)<>1  --> PEDIDO SEA DIFERENTE DE ELIMINADO
    );

    SET @CM_PEDIDO_APROBADO_EN_RECEPCION_CONFIRMADA =
    (
        SELECT ISNULL(SUM(PD.Cantidad), 0)
        FROM dbo.MM_PedidoDetalle AS PD
            INNER JOIN dbo.MM_Pedido AS P
                ON P.IdPedido = PD.IdPedido
            INNER JOIN dbo.MM_PeticionOferta AS PO
                ON PO.IdPeticionOferta = P.IdPeticionOferta
            INNER JOIN dbo.MM_PeticionOfertaDetalle AS POD
                ON POD.IdPeticionOferta = PO.IdPeticionOferta
            INNER JOIN dbo.MM_SolicitudPedido AS SP
                ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
            INNER JOIN dbo.MM_SolicitudPedidoDetalle AS SPD
                ON SPD.IdSolicitudPedido = SP.IdSolicitudPedido
            INNER JOIN dbo.TA_Operacion AS O
                ON O.IdDocumento = SP.IdSolicitudPedido
        WHERE SPD.IdSolicitudPedidoDetalle = @IdSolicitudPedidoDetalle
              AND POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
              AND PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
              AND O.IdTipoOperacion = @IdTipoOperacion
              AND P.Version = O.NoVersion
              AND O.IdEstatusOperacion = 2
              AND P.RecepcionServicio = 1
              AND PD.RecepcionPedido = 1
              AND POD.IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle
			  AND ISNULL(P.IdEstatusEliminado,0)<>1  --> PEDIDO SEA DIFERENTE DE ELIMINADO
    );

    SET @CM_DISPONIBILIDAD_FINAL
        = ((ISNULL(@CM_DISPONIBILIDAD, 0))
           - (ISNULL(@CM_PEDIDO_EN_APROBACION, 0) + ISNULL(@CM_PEDIDO_APROBADO_EN_RECEPCION, 0) + ISNULL(@CM_PEDIDO_APROBADO_EN_RECEPCION_CONFIRMADA, 0))
          );

	 
END;

