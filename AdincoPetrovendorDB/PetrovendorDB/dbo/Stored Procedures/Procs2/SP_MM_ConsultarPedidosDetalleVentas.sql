-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create  PROCEDURE [dbo].[SP_MM_ConsultarPedidosDetalleVentas]
	-- Add the parameters for the stored procedure here
	 
	@IdProveedorVentas int, 
	@IdPedido INT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	DECLARE @PROVEEDOR_COMPRAS INT = (SELECT IdProveedorCompras FROM MM_Pedido P WHERE IdSubcontratista = @IdProveedorVentas AND IdPedido = @IdPedido)	
		
	SELECT 
	 PD.IdPedidoDetalle,
	 PD.IdMaterialVendedor,
	 M.DescripcionCorta,
	 PD.PrecioUnitario,
	 PD.Cantidad,
	 TM.TipoMonedaCorto AS Moneda,
	 PD.Subtotal,
	 CASE PD.RecepcionPedido WHEN 1 THEN 'Confirmado' WHEN 0 THEN 'Rechazado'  else 'En confirmación' END  AS RecepcionPedido,
	 PD.PorcentajeContenidoNacional,
	 CONCAT(D.Calle,' ',D.NoInterior,' ',D.NoExterior,' ', D.Colonia ,' ',D.Municipio ,' ', D.Estado , ' CP ',D.CodigoPostal) AS DomicilioEntrega
	FROM MM_Pedido AS P
	INNER JOIN MM_PedidoDetalle AS PD ON PD.IdPedido = P.IdPedido
	INNER JOIN MM_PeticionOferta AS PO ON PO.IdPeticionOFerta = P.IdPeticionOferta
	INNER JOIN MM_PeticionOfertaDetalle AS POD ON POd.IdPeticionOfertaDetalle = PD.IdPeticionOfertaDetalle
	INNER JOIN MM_SolicitudPedidoDetalle AS SPD on SPD.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle
	INNER JOIN MM_Material AS M ON M.IdMaterial = PD.IdMaterialVendedor
	INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista
	INNER JOIN TA_Operacion AS O ON O.IdDocumento = P.IdSolicitudPedido
	INNER JOIN TA_Prioridad AS PR ON PR.IdPrioridad = O.IdPrioridad
	INNER JOIN TA_Vencimiento AS V ON V.IdVencimiento = O.IdVigencia
	INNER JOIN TA_TipoOperacion AS TTO ON TTO.IdTipoOperacion= O.IdTipoOperacion
	INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
	INNER JOIN PV_TipoMoneda AS TM ON TM.IdMoneda= PD.IdMoneda
	INNER JOIN DG_Domicilio AS D ON D.IdDomicilio = SPD.IdDomicilioEntrega
	WHERE O.IdTipoOperacion = 9 AND O.IdProveedor = @PROVEEDOR_COMPRAS AND P.IdPedido = @IdPedido
	GROUP BY  PD.IdPedidoDetalle,
	 PD.IdMaterialVendedor,
	 M.DescripcionCorta,
	 PD.PrecioUnitario,
	 PD.Cantidad,
	 TM.TipoMonedaCorto,
	 PD.Subtotal,
	 PD.RecepcionPedido,
	 PD.Subtotal,
	 PD.PorcentajeContenidoNacional,
	 D.Calle,D.NoInterior,D.NoExterior, D.Colonia,D.Municipio, D.Estado,D.CodigoPostal
	--- IdTipoOperacion = 9--> Aprobación de pedido


END


