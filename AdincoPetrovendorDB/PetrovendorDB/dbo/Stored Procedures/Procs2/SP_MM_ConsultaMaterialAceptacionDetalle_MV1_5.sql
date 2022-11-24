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
CREATE PROCEDURE [dbo].[SP_MM_ConsultaMaterialAceptacionDetalle_MV1_5] --516,36021
 -- Add the parameters for the stored procedure here  
	 @IdProveedor int,  
	 @IdPedidoDetalle INT,     
	 @IdContrato    INT = NULL,     
	 @IdUsuario     INT = NULL,     
	 @FechaRegistro DATETIME = NULL   
      
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
 DECLARE @CantidadYaAceptada FLOAT   
 DECLARE @CantidadSolicitadaPedido  FLOAT  
 DECLARE @CantidadFaltante FLOAT  
    -- Insert statements for procedure here  
   
   
 SET @CantidadYaAceptada = (SELECT 
								SUM(ISNULL(APD.Cantidad,0)) AS CantidadYaAceptada  
							 FROM MM_Pedido AS P WITH (NOLOCK) 
							 JOIN MM_PedidoDetalle AS PD WITH (NOLOCK) 
								ON PD.IdPedido = P.IdPedido 
							 JOIN MM_AceptacionPedido AS AP WITH (NOLOCK) 
								ON PD.IdPedido = AP.IdPedido  
									AND ISNULL(AP.IdEstatusEliminado,0)<>1
							 JOIN MM_AceptacionPedidoDetalle AS APD
								ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
									AND PD.IdPedidoDetalle = APD.IdPedidoDetalle
							 WHERE PD.IdPedidoDetalle= @IdPedidoDetalle )  
 /*SOLO SE TOMA EN CUENTA LAS CANTIDADES DE LAS ACEPTACIONES DE PEDIDO QUE NO ESTEN ELIMINADAS <> 1*/  
  
 SET @CantidadSolicitadaPedido = (SELECT PD.Cantidad   
								 FROM MM_PedidoDetalle AS PD WITH (NOLOCK)  
								 WHERE PD.IdPedidoDetalle =@IdPedidoDetalle)   
  
 SET @CantidadFaltante = ROUND(ISNULL(@CantidadSolicitadaPedido,0),5) - ROUND(ISNULL(@CantidadYaAceptada,0),5)  
  
 IF @CantidadFaltante < 0  
  SET @CantidadFaltante = 0  
    
	 SELECT   
		 PD.IdPedidoDetalle,  
		 ISNULL(POD.MaterialCotizadoTextoC,''),   
		 ISNULL(POD.UnidadProveedor,'Sin Especificar'),    
		 ROUND(PD.Cantidad,5),   
		 ROUND(ISNULL(@CantidadYaAceptada,0),5) As CantidadYaAceptada,   
		 ISNULL(M.IdMaterial,0),     
		 ISNULL(CONCAT(D.Calle,' ', D.NoExterior, ' ', D.NoInterior, ' ',D.Municipio, ' ', D.Estado,'', ' CP ',ISNULL(D.CodigoPostal,''),' ('+TD.TipoDomicilio,')'),'') AS DomicilioEntrega,  
		 ROUND(@CantidadFaltante,5) AS CantidadRestante  
	 FROM MM_Pedido AS P WITH (NOLOCK)
	 JOIN MM_PedidoDetalle  AS PD  WITH (NOLOCK)
		ON P.IdPedido = PD.IdPedido AND P.IdProveedorCompras = @IdProveedor 
	 JOIN MM_PeticionOfertaDetalle AS POD WITH (NOLOCK)
		ON PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle  
	 JOIN MM_SolicitudPedidoDetalle AS SPD WITH (NOLOCK)
		ON SPD.IdSolicitudPedidoDetalle  = POD.IdSolicitudPedidoDetalle  
	 LEFT JOIN MM_Material AS M WITH (NOLOCK)
		ON PD.IdMaterialVendedor =  M.IdMaterial
	 LEFT JOIN DG_Domicilio AS D WITH (NOLOCK)
		ON SPD.IdDomicilioEntrega = D.IdDomicilio 
	 LEFT JOIN DG_TipoDomicilio AS TD WITH (NOLOCK)
		ON D.IdTipoDomicilio = TD.IdTipoDomicilio
	 WHERE  
		PD.IdPedidoDetalle =@IdPedidoDetalle
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