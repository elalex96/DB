-- =============================================
-- Author:		Daniel AC
-- Create date: 14-04-17
-- Description:	Consultar Solicitudes de Oferta  
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaPedidosCliente]
	-- Add the parameters for the stored procedure here
@IdProveedor INT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

         SELECT SP.IdSolicitudPedido,
                O.FechaRegistro,
                TSP.TipoSolicitudPedido,
                O.Descripcion,
                E.Nombre AS Estatus
         FROM MM_SolicitudPedido AS SP
              INNER JOIN MM_TipoSolicitudPedido AS TSP ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
              INNER JOIN TA_Operacion AS O ON O.IdDocumento = SP.IdSolicitudPedido
                                              AND O.IdTipoOperacion = 7
              INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
         WHERE SP.IdProveedor = @IdProveedor;  


	--- IdTipoOperacion = 7--> Pedido


     END;
