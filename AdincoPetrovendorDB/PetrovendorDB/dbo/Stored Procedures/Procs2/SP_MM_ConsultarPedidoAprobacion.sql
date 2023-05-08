-- =============================================
-- Author:		Daniel AC
-- Create date: 18/06/2018
-- Description:	Consultar Pedido Detalle de aprobación de pedido 
-- =============================================
CREATE  PROCEDURE [dbo].[SP_MM_ConsultarPedidoAprobacion] 
	-- Add the parameters for the stored procedure here
	 
	@IdProveedorCompra int, 
	@IdSolicitudPedido int,
	@Version int 
	
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	SELECT 
	 PD.IdPedido,
	 PD.IdMaterialVendedor,
	 M.DescripcionCorta,
	 PD.PrecioUnitario,
	 PD.Cantidad,
	 TM.TipoMonedaCorto AS Moneda,
	 PD.Subtotal,
	 (PV.Razonsocial + ' '+ISNULL(PV.RegimenCapital,'')) AS Proveedor,
	 PG.IdPedido AS IdPedidoGeneral,
	 PD.IdPedidoDetalle
	 FROM MM_Pedido AS P
	INNER JOIN MM_PedidoDetalle AS PD ON PD.IdPedido = P.IdPedido
	INNER JOIN MM_PeticionOferta AS PO ON PO.IdPeticionOFerta = P.IdPeticionOferta
	INNER JOIN MM_Material AS M ON M.IdMaterial = PD.IdMaterialVendedor
	INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista
	INNER JOIN TA_Operacion AS O ON O.IdDocumento = P.IdSolicitudPedido
	INNER JOIN TA_Prioridad AS PR ON PR.IdPrioridad = O.IdPrioridad
	INNER JOIN TA_Vencimiento AS V ON V.IdVencimiento = O.IdVigencia
	INNER JOIN TA_TipoOperacion AS TTO ON TTO.IdTipoOperacion= O.IdTipoOperacion
	INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
	LEFT JOIN PV_TipoMoneda AS TM ON TM.IdMoneda= PD.IdMoneda
	LEFT JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = @IdProveedorCompra
	LEFT JOIN  MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
	WHERE O.IdTipoOperacion = 9 AND O.IdProveedor = @IdProveedorCompra AND P.IdSolicitudPedido = @IdSolicitudPedido  AND P.Version=@Version
	GROUP BY 
	PD.IdPedido,
	PD.IdMaterialVendedor,
	M.DescripcionCorta,
	PD.PrecioUnitario,
	PD.Cantidad,
	TM.TipoMonedaCorto,
	PD.Subtotal,
	PV.Razonsocial,
	PV.RegimenCapital,
	PG.IdPedido,
	PD.IdPedidoDetalle
	  
	--- IdTipoOperacion = 9--> Aprobación de pedido


END

