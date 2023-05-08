-- =============================================
-- Author:		Daniel AC
-- Create date: 14-04-17
-- Description:	Consultar Pedido Detalle iTEMS DE 
-- =============================================
CREATE  PROCEDURE [dbo].[SP_MM_ConsultarPrePedidosDetalleCompras]
	-- Add the parameters for the stored procedure here
	 
	@IdProveedorVenta int, 
	@IdPedido int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		
	SELECT 
	 PD.IdPedidoDetalle,
	 PD.IdMaterialVendedor,
	 M.DescripcionCorta,
	 PD.PrecioUnitario,
	 PD.Cantidad,
	 TM.TipoMonedaCorto AS Moneda,
	 PD.Subtotal
	 FROM MM_Pedido AS P
	INNER JOIN MM_PedidoDetalle AS PD ON PD.IdPedido = P.IdPedido
	INNER JOIN MM_PeticionOferta AS PO ON PO.IdPeticionOFerta = P.IdPeticionOferta
	INNER JOIN MM_Material AS M ON M.IdMaterial = PD.IdMaterialVendedor
	INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista
	INNER JOIN TA_Operacion AS O ON O.IdDocumento = P.IdPedido
	INNER JOIN TA_Prioridad AS PR ON PR.IdPrioridad = O.IdPrioridad
	INNER JOIN TA_Vencimiento AS V ON V.IdVencimiento = O.IdVigencia
	INNER JOIN TA_TipoOperacion AS TTO ON TTO.IdTipoOperacion= O.IdTipoOperacion
	INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
	INNER JOIN PV_TipoMoneda AS TM ON TM.IdMoneda= PD.IdMoneda
	WHERE O.IdTipoOperacion = 9 AND O.IdProveedor = @IdProveedorVenta AND P.IdPedido = @IdPedido
	  
	--- IdTipoOperacion = 9--> Aprobación de pedido


END

