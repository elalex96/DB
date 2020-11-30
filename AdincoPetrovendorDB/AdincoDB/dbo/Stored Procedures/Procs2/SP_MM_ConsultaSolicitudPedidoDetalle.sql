-- =============================================
-- Author:		Daniel AC
-- Create date: 24-04-17
-- Description: Consulta Solicitud Pedido Detalle 
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaSolicitudPedidoDetalle]
	-- Add the parameters for the stored procedure here

@IdSolicitudPedido INT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

         SELECT SPD.IdSolicitudPedidoDetalle,
                M.DescripcionCorta,
                SPD.IdMaterial,
                SPD.Cantidad,
                SPD.Observaciones
         FROM MM_SolicitudPedidoDetalle AS SPD
              INNER JOIN MM_Material AS M ON M.IdMaterial = SPD.IdMaterial
         WHERE IdSolicitudPedido = @IdSolicitudPedido;
     END;
