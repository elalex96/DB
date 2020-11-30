-- =============================================
-- Author:		Pedro Acuña
-- Create date: 06/02/2020
-- Description:	se revisa el tipo de solicitud de pedido para saber a donde va a redirigir la pagina por el tipo de adjudicacion : mercadeo o directa MM_TipoPedido
-- =============================================

CREATE PROCEDURE BibliotecaObtenerTipoSolicitudPedido @IdSolicitudPedido INT, 
                                                      @idProveedor       INT
AS
    BEGIN
        SELECT IdTipoProceso
        FROM dbo.MM_SolicitudPedido
        WHERE IdSolicitudPedido = @IdSolicitudPedido
              AND IdProveedor = @idProveedor;
    END;
