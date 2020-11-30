-- =============================================    
-- Author:  Pedro Acuña    
-- Create date: 25-05-17    
-- Description: Se agrega los dias de credito al retorno    
-- =============================================    
-- Author:  Daniel AC    
-- Create date: 28-10-2018    
-- Description: Personalización para días de crédito por partida   
-- =============================================    
CREATE PROCEDURE SP_MM_ConsultaOrdenCompra    
 -- Add the parameters for the stored procedure here    
  @IdPedido INT,    
  @IdProveedor INT    
AS    
     BEGIN    
 -- SET NOCOUNT ON added to prevent extra result sets from    
 -- interfering with SELECT statements.    
         SET NOCOUNT ON;    
    
   --SELECT * FROM  dbo.TA_Operacion WHERE IdDocumento = 14074    
   --SELECT *  FROM dbo.TA_Tarea WHERE IdOperacion = 4995    
   --SELECT * FROM dbo.TA_Aprobador     
    DECLARE @CondionesPago NVARCHAR(MAX)   
  
 SELECT   
 @CondionesPago=CASE WHEN pd.IdCondicionPago = 1 THEN --> CREDITO  
 CONCAT(pd.DiasCredito, CASE WHEN PD.DiasCredito=1 THEN ' días' ELSE ' días' END,' de ', cp.CondicionPago)  
 ELSE   
 CONCAT(cp.CondicionPago,'')  
 END   
 FROM dbo.MM_PedidoDetalle pd  
 LEFT JOIN dbo.MM_CondicionPago cp ON cp.IdCondicionPago = pd.IdCondicionPago  
 WHERE IdPedido =@IdPedido  
     
 SELECT     
 P.IdPedido,    
 P.IdSolicitudPedido,    
 SUM(PD.Subtotal) AS SubTotal,    
 O.IdOperacion,     
 O.Descripcion,     
 ISNULL(PV.RazonSocial,'') +' ' + ISNULL(PV.RegimenCapital,'') AS Proveedor,    
 PV.Municipio +' '+PV.Entidad AS LugarProveedor,    
 ISNULL(P.FechaEnvioPedido, GETDATE()) AS FechaEnvioPedido,    
 P.IdPeticionOferta,    
 P.RecepcionServicio,    
 ISNULL(P.FechaRecepcionServicio,GETDATE()),    
 ISNULL(H.FechaVigencia, GETDATE()),    
 PG.IdPedido,    
 TP.TipoPedido,    
 TP.IdTipoPedido,    
 P.DiasCredito,    
  ISNULL(P.Cerrado, 0) AS Cerrado,  
 CASE WHEN P.UnicaCondicionPago = 1 THEN   
 CONCAT(@CondionesPago,'')  
 ELSE   
 'Diferidas para las partidas de la orden de compra'  
 END AS CondicionesPago    
 FROM MM_Pedido AS P    
 INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = P.IdProveedorCompras AND PG.IdTipoPedido in (2,4, 6)   
 LEFT  JOIN dbo.MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido    
 LEFT JOIN MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = P.IdSolicitudPedido    
 LEFT JOIN MM_PedidoDetalle AS PD ON PD.IdPedido = P.IdPedido    
 LEFT JOIN TA_Operacion AS O ON O.IdDocumento = P.IdSolicitudPedido AND P.Version = O.NoVersion    
 --LEFT JOIN TA_Tarea AS TA ON TA.IdOperacion = O.IdOperacion    
 LEFT JOIN TA_TipoOperacion AS TTO ON TTO.IdTipoOperacion= O.IdTipoOperacion      
 LEFT JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion    
 LEFT JOIN S_Usuario AS U  ON U.IdUsuario = O.IdAsignador    
 LEFT JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdProveedorCompras     
 LEFT JOIN CC_CentroCosto AS CC ON SP.IdCentroCosto = CC.IdCentrocosto     
 LEFT JOIN dbo.MM_HorasVigenciaPedido AS H ON H.IdPedido = P.IdPedido    
 WHERE O.IdTipoOperacion = 9 AND P.IdSubcontratista = @IdProveedor AND P.IdPedido = @IdPedido AND O.IdEstatusOperacion=2    
 GROUP BY     
 P.IdPedido,     
 P.IdSolicitudPedido,    
 --PD.Subtotal,    
 O.IdOperacion,     
 O.Descripcion,     
 PV.RazonSocial,     
 PV.RegimenCapital,    
 Pv.Municipio,    
 PV.Entidad,     
 P.FechaEnvioPedido,    
 P.IdPeticionOferta,    
 P.RecepcionServicio,    
 P.FechaRecepcionServicio,    
 H.FechaVigencia,    
 PG.IdPedido,    
 TP.TipoPedido,    
 TP.IdTipoPedido,    
 P.DiasCredito,    
 P.Cerrado ,  
 P.UnicaCondicionPago  
        
   --- EXECUTE [SP_MM_ConsultaOrdenCompra] 1343,427    
  END;  