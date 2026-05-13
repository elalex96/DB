-- =============================================
-- Author:		Daniel AC
-- Create date: 14-04-17
-- Description:	Consultar Pedido Detalle iTEMS DE 
-- =============================================
CREATE  PROCEDURE [dbo].[SP_MM_ConsultarPedidosDetalleCompras] --498, 10024
	-- Add the parameters for the stored procedure here
	 
	@IdProveedorCompras int, 
	@IdPedido INT
	
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
	 PD.Subtotal,
	 CASE 
	 WHEN PD.RecepcionPedido = 1 AND P.RecepcionServicio=1 THEN 'Confirmado' 
	 WHEN PD.RecepcionPedido = 0 AND (P.RecepcionServicio=1  OR P.RecepcionServicio=0)THEN 'Rechazado' 
	 WHEN P.RecepcionServicio IS NULL AND (DATEDIFF(MINUTE,HV.FechaVigencia, GETDATE()))  >= 0 THEN
		'Vencida' 
	 ELSE 
		'En confirmación' 
	 END  AS RecepcionPedido,
	 PD.PorcentajeContenidoNacional,
	 CONCAT(D.Calle,' ',D.NoInterior,' ',D.NoExterior,' ', D.Colonia ,' ',D.Municipio ,' ', D.Estado , ' CP ',D.CodigoPostal) AS DomicilioEntrega,
	 HV.FechaVigencia,
	 P.IdPedido,
	 P.RecepcionServicio,
	 PD.RecepcionPedido
	FROM MM_Pedido AS P
	LEFt JOIN MM_PedidoDetalle AS PD ON PD.IdPedido = P.IdPedido
	LEFt JOIN MM_PeticionOferta AS PO ON PO.IdPeticionOFerta = P.IdPeticionOferta
	LEFt JOIN MM_PeticionOfertaDetalle AS POD ON POd.IdPeticionOfertaDetalle = PD.IdPeticionOfertaDetalle
	LEFT JOIN MM_SolicitudPedidoDetalle AS SPD on SPD.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle
	LEFt JOIN MM_Material AS M ON M.IdMaterial = PD.IdMaterialVendedor
	LEFT JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista
	LEFT JOIN TA_Operacion AS O ON O.IdDocumento = P.IdSolicitudPedido
	LEFT JOIN TA_Prioridad AS PR ON PR.IdPrioridad = O.IdPrioridad
	LEFT JOIN TA_Vencimiento AS V ON V.IdVencimiento = O.IdVigencia
	LEFT JOIN TA_TipoOperacion AS TTO ON TTO.IdTipoOperacion= O.IdTipoOperacion
	LEFt JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
	LEFT JOIN PV_TipoMoneda AS TM ON TM.IdMoneda= PD.IdMoneda
	LEFt JOIN DG_Domicilio AS D ON D.IdDomicilio = SPD.IdDomicilioEntrega
	LEFT JOIN dbo.MM_HorasVigenciaPedido AS HV ON HV.IdPedido=P.IdPedido
	WHERE O.IdTipoOperacion = 9 AND O.IdProveedor = @IdProveedorCompras AND P.IdPedido = @IdPedido
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
	 D.Calle,D.NoInterior,D.NoExterior, D.Colonia,D.Municipio, D.Estado,D.CodigoPostal,
	  HV.FechaVigencia,
	  P.IdPedido,
	  P.RecepcionServicio
	--- IdTipoOperacion = 9--> Aprobación de pedido


END

