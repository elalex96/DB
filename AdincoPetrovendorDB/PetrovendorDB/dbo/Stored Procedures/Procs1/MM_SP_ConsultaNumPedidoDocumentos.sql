-- =============================================
-- Author:		Pedro Acuña
-- Create date: <11-12-2018>
-- Description:	<store para revisar cual es el numero de pedido para adjuntarle documentos>
-- Ya que no se sabe el numero de pedido los filtros son la solicitud de pedido, el monto del pedido, la moneda, la version y el subcontratista
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: <31-10-2019>
-- Description:	Se removio el parametro de monto total del pedido y se agrego el parametro @IdPeticionOferta
-- =============================================

CREATE PROCEDURE MM_SP_ConsultaNumPedidoDocumentos
    @IdSolicitudPedido INT,
    @IdMoneda INT,
    @Version INT,
    @IdSubcontratista INT, 
    @IdContrato INT = NULL,
    @IdUsuario INT = NULL,
    @FechaRegistro DATETIME = NULL,
	@IdPeticionOferta INT 
AS
BEGIN
    SELECT TOP 1
           p.IdPedido
    FROM dbo.MM_Pedido p
        INNER JOIN dbo.MM_PedidoDetalle pd
            ON pd.IdPedido = p.IdPedido
    WHERE p.IdSolicitudPedido = @IdSolicitudPedido
          AND p.Version = @Version
          AND p.IdSubcontratista = @IdSubcontratista
          AND pd.IdMoneda = @IdMoneda
		  AND p.IdPeticionOferta=@IdPeticionOferta
          AND ISNULL(p.IdEliminado, 0) = 0
    GROUP BY p.IdPedido
    --HAVING SUM(pd.Subtotal) = @TotalPedido;
END;
