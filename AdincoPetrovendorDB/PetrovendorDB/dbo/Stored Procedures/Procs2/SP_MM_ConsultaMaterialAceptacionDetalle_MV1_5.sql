-- =============================================  
-- Author:  Daniel AC  
-- Create date: 24-06-17  
-- Description: Consultar detalle de cantidades Recepcion Pedido detalle  
-- =============================================  
-- =============================================  
-- Author:  Daniel AC  
-- Create date: 24-06-17  
-- Description: Validación de solo mostrar información de aceptaciones que no tengan un estatus de eliminado = 1  
-- =============================================  
CREATE PROCEDURE [dbo].[SP_MM_ConsultaMaterialAceptacionDetalle_MV1_5]  
 -- Add the parameters for the stored procedure here  
 @IdProveedor int,  
 @IdPedidoDetalle INT,     @IdContrato    INT,     @IdUsuario     INT,     @FechaRegistro DATETIME    
      
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
 DECLARE @CantidadYaAceptada FLOAT   
 DECLARE @CantidadSolicitadaPedido  FLOAT  
 DECLARE @CantidadFaltante FLOAT  
    -- Insert statements for procedure here  
   
   
 SET @CantidadYaAceptada=   
 (SELECT SUM(ISNULL(APD.Cantidad,0)) AS CantidadYaAceptada  
 FROM MM_AceptacionPedidoDetalle AS APD  
 INNER JOIN MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido= APD.IdAceptacionPedido  
 INNER JOIN MM_Pedido AS P ON P.IdPedido = AP.IdPedido  
 INNER JOIN MM_PedidoDetalle AS PD ON PD.IdPedidoDetalle = APD.IdPedidoDetalle  
 WHERE  PD.IdPedidoDetalle= @IdPedidoDetalle AND ISNULL(AP.IdEstatusEliminado,0)<>1)  
 /*SOLO SE TOMA EN CUENTA LAS CANTIDADES DE LAS ACEPTACIONES DE PEDIDO QUE NO ESTEN ELIMINADAS <> 1*/  
  
 SET @CantidadSolicitadaPedido =   
 (SELECT PD.Cantidad   
 FROM MM_PedidoDetalle AS PD   
 WHERE PD.IdPedidoDetalle =@IdPedidoDetalle)   
  
 SET @CantidadFaltante = ROUND(ISNULL(@CantidadSolicitadaPedido,0),3) - ROUND(ISNULL(@CantidadYaAceptada,0),3)  
  
 IF @CantidadFaltante < 0  
  SET @CantidadFaltante = 0  
    
 SELECT   
 PD.IdPedidoDetalle,  
 ISNULL(POD.MaterialCotizadoTextoC,''),   
 ISNULL(POD.UnidadProveedor,'Sin Especificar'),    
 ROUND(PD.Cantidad,3),   
 ROUND(ISNULL(@CantidadYaAceptada,0),3) As CantidadYaAceptada,   
 ISNULL(M.IdMaterial,0),     
    ISNULL(CONCAT(D.Calle,' ', D.NoExterior, ' ', D.NoInterior, ' ',D.Municipio, ' ', D.Estado,'', ' CP ',ISNULL(D.CodigoPostal,''),' ('+TD.TipoDomicilio,')'),'') AS DomicilioEntrega,  
 ROUND(@CantidadFaltante,3) AS CantidadRestante  
 FROM MM_PedidoDetalle  AS PD  
 INNER JOIN MM_Pedido AS P ON P.IdPedido = PD.IdPedido    
 INNER JOIN MM_Material AS M ON M.IdMaterial = PD.IdMaterialVendedor   
 INNER JOIN MM_PeticionOfertaDetalle AS POD ON POD.IdPeticionOfertaDetalle = PD.IdPeticionOfertaDetalle  
 INNER JOIN MM_SolicitudPedidoDetalle AS SPD ON SPD.IdSolicitudPedidoDetalle  = POD.IdSolicitudPedidoDetalle  
 LEFT JOIN DG_Domicilio AS D ON D.IdDomicilio = SPD.IdDomicilioEntrega  
 LEFT JOIN DG_TipoDomicilio AS TD ON TD.IdTipoDomicilio = D.IdTipoDomicilio  
 WHERE  PD.IdPedidoDetalle =@IdPedidoDetalle AND P.IdProveedorCompras=@IdProveedor  
 GROUP BY  
 PD.IdPedidoDetalle,  
 POD.MaterialCotizadoTextoC,   
 POD.UnidadProveedor,  
 PD.Cantidad,  
 M.IdMaterial,    
    D.Calle,   
 D.NoExterior,    
 D.NoInterior,  
 D.Municipio,  
 D.Estado,  
 D.CodigoPostal,  
 TD.TipoDomicilio  
  
   
    
END