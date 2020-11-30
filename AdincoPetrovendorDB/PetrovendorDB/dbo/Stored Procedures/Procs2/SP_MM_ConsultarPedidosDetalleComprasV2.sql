-- =============================================
-- Author:		Daniel AC
-- Create date: 14-04-17
-- Description:	Consultar Pedido Detalle iTEMS DE 
-- =============================================
CREATE  PROCEDURE [dbo].[SP_MM_ConsultarPedidosDetalleComprasV2]
	-- Add the parameters for the stored procedure here

	@IdPedido INT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @PROVEEDOR_COMPRAS INT = (SELECT IdProveedorCompras FROM MM_Pedido P WHERE IdPedido = @IdPedido)		

	SELECT 
	ROW_NUMBER() OVER(ORDER BY PD.IdPedidoDetalle ASC) AS Partida,
	 PD.IdPedidoDetalle,
	 PD.IdMaterialVendedor,
	 M.DescripcionCorta,
	 UN.Unidad,
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
	 CASE WHEN SP.EntregasParciales = 1 THEN
		CONVERT(VARCHAR(11),SP.FechaEntregaRequerida,103) +' - '+ CONVERT(VARCHAR(11),SP.FechaEntregaFinRequerida,103) 
	  ELSE 
		CONVERT(VARCHAR(11),SP.FechaEntregaRequerida,103) 
	 END AS FechaEntrega,
	 UN.Unidad,
	 dbo.CantidadConLetra(PD.Subtotal) AS SubtotalLetra,
	 PD.RecepcionPedido,
	 SPD.observaciones
	FROM MM_Pedido AS P
	LEFT JOIN MM_PedidoDetalle AS PD ON PD.IdPedido = P.IdPedido
	LEFT JOIN MM_PeticionOferta AS PO ON PO.IdPeticionOFerta = P.IdPeticionOferta
	LEFT JOIN MM_PeticionOfertaDetalle AS POD ON POd.IdPeticionOfertaDetalle = PD.IdPeticionOfertaDetalle
	LEFT JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido=P.IdSolicitudPedido
	LEFT JOIN MM_SolicitudPedidoDetalle AS SPD on SPD.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle
	LEFT JOIN MM_Material AS M ON M.IdMaterial = PD.IdMaterialVendedor
	LEFT JOIN TA_Operacion AS O ON O.IdDocumento = P.IdSolicitudPedido
	LEFT JOIN TA_Prioridad AS PR ON PR.IdPrioridad = O.IdPrioridad
	LEFT JOIN TA_Vencimiento AS V ON V.IdVencimiento = O.IdVigencia
	LEFT JOIN TA_TipoOperacion AS TTO ON TTO.IdTipoOperacion= O.IdTipoOperacion
	LEFT JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
	LEFT JOIN dbo.PV_MM_MaterialUnidad AS UN ON UN.IdUnidad = M.IdUnidad
	LEFT JOIN PV_TipoMoneda AS TM ON TM.IdMoneda= PD.IdMoneda
	LEFT JOIN DG_Domicilio AS D ON D.IdDomicilio = SPD.IdDomicilioEntrega
	LEFT JOIN dbo.MM_HorasVigenciaPedido AS HV ON HV.IdPedido=P.IdPedido
	WHERE O.IdTipoOperacion = 9 AND P.IdPedido = @IdPedido
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
	  P.FechaEntrega,
	  P.IdPedido,
	  UN.Unidad,
	  SPD.observaciones,
	  P.RecepcionServicio,	  
	  SP.FechaEntregaRequerida,
	  SP.FechaEntregaFinRequerida,
	  SP.EntregasParciales 
	--- IdTipoOperacion = 9--> Aprobación de pedido


END

