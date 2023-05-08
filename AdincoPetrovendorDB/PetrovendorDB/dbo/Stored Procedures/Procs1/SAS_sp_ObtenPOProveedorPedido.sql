-- =============================================
-- Author:		Luis David
-- Create date: 19/04/2022
-- Description:	Se obtiene el PO Number y el subcontratista de la acepación de pedido
-- =============================================
CREATE PROCEDURE SAS_sp_ObtenPOProveedorPedido
@IdPedido int,
@IdProveedor int
AS
BEGIN
SELECT  
		 ISNULL(ISNULL(WPI.PURCHASING_DOCUMENT,POW.PO),'SIN PO RELACIONADO') AS NoPO,
		 CONCAT(PV.RazonSocial, ' ', PV.RegimenCapital)
		 FROM MM_Pedido AS P    
		 INNER JOIN MM_Pedidos AS PG 
			ON P.IdPedido = PG.IdIdentificador 
			AND PG.IdProveedorCliente = P.IdProveedorCompras 
			AND PG.IdTipoPedido in (2,4,6)   
		 LEFT JOIN MM_SolicitudPedido AS SP 
			ON P.IdSolicitudPedido = SP.IdSolicitudPedido    
		 LEFT JOIN MM_PedidoDetalle AS PD 
			ON P.IdPedido = PD.IdPedido    
		 LEFT JOIN TA_Operacion AS O
			ON P.IdSolicitudPedido  = O.IdDocumento
			AND P.Version = O.NoVersion    		 
		 LEFT JOIN S_Proveedor AS PV 
			ON P.IdSubcontratista = PV.IdProveedor
		 LEFT JOIN CC_CentroCosto AS CC 
			ON SP.IdCentroCosto = CC.IdCentrocosto     
		 LEFT JOIN dbo.MM_HorasVigenciaPedido AS H 
			ON P.IdPedido = H.IdPedido   
		LEFT JOIN WDEA_PurchasingDocumentsImportados AS WPI
			ON P.IdPedido = WPI.IdPedidoADINCO
		LEFT JOIN DEA_Relacion_PR_PO AS POW
			ON P.IdPedido = POW.IdPedido 
		 WHERE O.IdTipoOperacion = 9 
			AND P.IdSubcontratista = @IdProveedor --IdProveedor
			AND P.IdPedido = @IdPedido -- @IdPedido
			AND O.IdEstatusOperacion=2 
END