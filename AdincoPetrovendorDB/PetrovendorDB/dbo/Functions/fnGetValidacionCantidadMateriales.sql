DROP FUNCTION IF EXISTS fnGetValidacionCantidadMateriales
GO
CREATE FUNCTION fnGetValidacionCantidadMateriales
(@IdPedidoDetalle int,
@IdPedido int,  
@Cantidad FLOAT)
RETURNS VARCHAR(MAX)
AS
BEGIN
DECLARE @CantidadSolicitadaPedido FLOAT  = 0  ,@CantidadYaAceptada FLOAT  = 0  ,@CantidadFaltante FLOAT = 0, @mensajeValidacion varchar(max);
  
   
 SET @CantidadYaAceptada=   
 (SELECT SUM(ISNULL(APD.Cantidad,0)) AS CantidadYaAceptada  
 FROM MM_AceptacionPedidoDetalle AS APD  
 INNER JOIN MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido= APD.IdAceptacionPedido  
 INNER JOIN MM_Pedido AS P ON P.IdPedido = AP.IdPedido  
 INNER JOIN MM_PedidoDetalle AS PD ON PD.IdPedidoDetalle = APD.IdPedidoDetalle  
 WHERE P.IdPedido= @IdPedido AND PD.IdPedidoDetalle= @IdPedidoDetalle AND ISNULL(AP.IdEstatusEliminado,0)<>1)  
 /*SOLO SE TOMA EN CUENTA LAS CANTIDADES DE LAS ACEPTACIONES DE PEDIDO QUE NO ESTEN ELIMINADAS <> 1*/  
  
 SET @CantidadSolicitadaPedido =   
 (SELECT PD.Cantidad  
 FROM MM_PedidoDetalle AS PD   
 WHERE PD.IdPedidoDetalle =@IdPedidoDetalle  AND PD.IdPedido= @IdPedido)  
  
   
  
 SET @CantidadFaltante = ROUND(ISNULL(@CantidadSolicitadaPedido,0),5) - ROUND(ISNULL(@CantidadYaAceptada,0),5)  
  
    IF @CantidadFaltante < 0  
  SET @CantidadFaltante = 0  
  
   IF @Cantidad > ROUND(@CantidadFaltante,5)  
    BEGIN  
		set @mensajeValidacion = ('CANTIDAD_INVALIDA')
    END   
   ELSE   
    BEGIN  
		set @mensajeValidacion = ( 'CANTIDAD_VALIDA'/*+CAST(ROUND(ISNULL(@CantidadFaltante,0),5) AS NVARCHAR(MAX))*/)
    END   
	return @mensajeValidacion
END