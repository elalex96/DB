-- =============================================
-- Author:		Daniel AC
-- Create date: 14-04-17
-- Description:	Actualizar Aceptacion de Servicio de pedido detalle
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ActualizarAceptacionServicioPedidoDetalle]
	-- Add the parameters for the stored procedure here
@IdPedidoDetalle    INT,
@IdUsuario          INT,
@AceptacionServicio BIT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

         UPDATE MM_PedidoDetalle
           SET
               AceptacionServicio = @AceptacionServicio,
               FechaAceptacionServicio = GETDATE(),
               IdUsuarioAceptacionServicio = @IdUsuario
         WHERE IdPedidoDetalle = @IdPedidoDetalle;
     END;
