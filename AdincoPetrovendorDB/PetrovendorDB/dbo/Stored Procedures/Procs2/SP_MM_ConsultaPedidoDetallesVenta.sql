-- =============================================
-- Author:		Daniel AC
-- Create date: 25-05-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaPedidoDetallesVenta] 
	-- Add the parameters for the stored procedure here
@IdProveedor INT,
@IdPedido    INT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here
	 

		SELECT 
		PD.IdPedidoDetalle,
		PD.IdMaterialVendedor,
		M.Descripcioncorta,
		PD.Cantidad,
		PD.PrecioUnitario,
		PD.Subtotal, 
		TM.TipoMonedaCorto,
		PD.PorcentajeContenidoNacional,
		ISNULL(PD.RecepcionPedido,'false')  AS Recepcionservicio,
		Version,
		PD.RecepcionPedido		
		FROM MM_Pedido AS P
		INNER JOIN MM_PedidoDetalle AS PD ON PD.IdPedido = P.IdPedido 
		INNER JOIN MM_Material AS M ON M.IdMaterial = PD.IdMaterialVendedor
		INNER JOIN MM_PeticionOferta AS PO ON PO.IdPeticionOFerta = P.IdPeticionOferta
		INNER JOIN MM_SolicitudPedido AS SP ON PO.IdSolicitudPedido = SP.IdSolicitudPedido
		INNER JOIN MM_PeticionOfertaDetalle AS POD ON PO.IdPeticionOferta = POD.IdPeticionOferta AND POD.IdMaterial = PD.IdMaterial
		INNER JOIN MM_SolicitudPedidoDetalle AS SPD ON SPD.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle
		INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista
		INNER JOIN TA_Operacion AS O ON O.IdDocumento = P.IdSolicitudPedido
		INNER JOIN TA_Prioridad AS PR ON PR.IdPrioridad = O.IdPrioridad
		INNER JOIN TA_Vencimiento AS V ON V.IdVencimiento = O.IdVigencia
		INNER JOIN TA_TipoOperacion AS TTO ON TTO.IdTipoOperacion= O.IdTipoOperacion
		INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
		INNER JOIN PV_TipoMoneda AS TM ON TM.IdMoneda = PD.IdMoneda 
		INNER JOIN DG_Domicilio  AS D ON D.IdDomicilio = SPD.IdDomicilioEntrega	
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
		Version	
		 
 
     END;

