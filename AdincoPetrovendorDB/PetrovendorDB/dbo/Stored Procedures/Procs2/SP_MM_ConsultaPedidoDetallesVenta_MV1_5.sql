-- =============================================
-- Author:		Daniel AC
-- Create date: 28-10-2019
-- Description:	Consultar materiales de orden de compra y se agrego detalle de condición de pago
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaPedidoDetallesVenta_MV1_5] 
	-- Add the parameters for the stored procedure here
@IdProveedor INT,
@IdPedido    INT,
@IdContrato    INT,
@IdUsuario     INT,
@FechaRegistro DATETIME

AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Donde O.IdTipoOperacion = 9  Aprobación de pedido y O.IdEstatusOperacion = 2 Aprobada
	 

		SELECT 
		PD.IdPedidoDetalle,
		PD.IdMaterialVendedor,
		POD.MaterialCotizadoTextoC AS Descripcioncorta,
		POD.MaterialCotizadoTextoL AS Descripcionlarga,
		PD.Cantidad,
		PD.PrecioUnitario,
		PD.Subtotal, 
		TM.TipoMonedaCorto,
		PD.PorcentajeContenidoNacional,
		ISNULL(PD.RecepcionPedido,'false')  AS Recepcionservicio,
		Version,
		PD.RecepcionPedido,
		POD.UnidadProveedor AS UnidadCotizada,
		CASE WHEN PD.IdCondicionPago= 1 THEN ---> CREDITO
			CONCAT(PD.DiasCredito, ' ',CASE WHEN PD.DiasCredito= 1 THEN 'día' ELSE 'días'END,' de ', CP.CondicionPago )
			ELSE 
			cp.CondicionPago
			END  AS CondicionPago		
		FROM MM_Pedido AS P
		INNER JOIN MM_PedidoDetalle AS PD ON PD.IdPedido = P.IdPedido
		INNER JOIN MM_Material AS M ON M.IdMaterial = PD.IdMaterialVendedor
		INNER JOIN MM_PeticionOferta AS PO ON PO.IdPeticionOFerta = P.IdPeticionOferta
		INNER JOIN MM_SolicitudPedido AS SP ON PO.IdSolicitudPedido = SP.IdSolicitudPedido
		INNER JOIN MM_PeticionOfertaDetalle AS POD ON PO.IdPeticionOferta = POD.IdPeticionOferta AND POD.IdMaterial = PD.IdMaterial 
		AND pd.IdUnidadProveedor = pod.IdUnidadProveedor AND pd.IdPeticionOfertaDetalle = pod.IdPeticionOfertaDetalle 
		INNER JOIN MM_SolicitudPedidoDetalle AS SPD ON SPD.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle AND SPD.IdSolicitudPedido=SP.IdSolicitudPedido
		INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista
		INNER JOIN TA_Operacion AS O ON O.IdDocumento = P.IdSolicitudPedido AND P.Version = O.NoVersion
		INNER JOIN TA_Prioridad AS PR ON PR.IdPrioridad = O.IdPrioridad
		INNER JOIN TA_Vencimiento AS V ON V.IdVencimiento = O.IdVigencia
		INNER JOIN TA_TipoOperacion AS TTO ON TTO.IdTipoOperacion= O.IdTipoOperacion
		INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
		INNER JOIN PV_TipoMoneda AS TM ON TM.IdMoneda = PD.IdMoneda 
		LEFT JOIN DG_Domicilio  AS D ON D.IdDomicilio = SPD.IdDomicilioEntrega
		LEFT JOIN dbo.MM_CondicionPago CP ON PD.IdCondicionPago=CP.IdCondicionPago	
		WHERE O.IdTipoOperacion = 9 AND P.IdSubcontratista = @IdProveedor AND O.IdEstatusOperacion = 2 AND P.IdPedido = @IdPedido
		GROUP BY 
		PD.IdPedidoDetalle,PD.IdMaterialVendedor,
		M.Descripcioncorta,
		PD.Cantidad,
		PD.PrecioUnitario,
		PD.Subtotal, 
		TM.TipoMonedaCorto,
		PD.PorcentajeContenidoNacional,
		PD.RecepcionPedido,
		SPD.IdDomicilioEntrega,
		Version	,
		POD.MaterialCotizadoTextoC,
		POD.MaterialCotizadoTextoL,
		POD.UnidadProveedor,
		PD.IdCondicionPago,
		PD.DiasCredito,
		cp.CondicionPago
 
     END;

	

