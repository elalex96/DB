-- =============================================
-- Author:		Daniel AC
-- Create date: 14-04-17
-- Description:	Consultar Pedido Detalle que tienen un estatus de recepción de pedido Pendiente 
-- =============================================
CREATE  PROCEDURE [dbo].[SP_MM_ConsultaPedidoDetalleAceptadoCliente]
	-- Add the parameters for the stored procedure here
	@IdPedido int,
	@IdProveedorVenta int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		
	SELECT PD.IdPedidoDetalle, 
	P.IdPedido,
	PD.IdMaterial, 
	M.DescripcionCorta, 
	PV.RazonSocial,
	POD.AddCantidadTemp, 
	POD.AddSubTotalTemp,
	ISNULL(PD.RecepcionPedido, 'false') AS RecepcionPedido, 
	ISNULL(PD.AceptacionServicio, 'false')  As AceptacionServicio,
	POD.PrecioUnitario AS PrecioUnitario,
	PD.ComentarioAceptacionServicio
	FROM MM_PedidoDetalle AS PD
	INNER JOIN MM_Pedido AS P ON P.IdPedido = PD.IdPedido
	INNER JOIN MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = P.IdSolicitudPedido
	INNER JOIN TA_Operacion AS TAO ON TAO.IdDocumento = SP.IdSolicitudPedido 
	INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista
	INNER JOIN MM_Material AS M ON M.IdMaterial = PD.IdMaterial 
	INNER JOIN MM_PeticionOfertaDetalle AS POD ON POD.IdPeticionOfertaDetalle = PD.IdPeticionOfertaDetalle
	WHERE TAO.IdTipoOperacion = 7
	AND SP.IdProveedor=@IdProveedorVenta
	AND RecepcionPedido = 1
	AND P.IdPedido = @IdPedido
	ORDER BY DescripcionCorta ASC

	--- IdTipoOperacion = 7--> Pedido
	
END

