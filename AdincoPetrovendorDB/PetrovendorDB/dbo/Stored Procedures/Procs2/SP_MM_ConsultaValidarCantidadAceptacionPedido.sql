USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MM_ConsultaValidarCantidadAceptacionPedido'
)
    DROP PROCEDURE SP_MM_ConsultaValidarCantidadAceptacionPedido;
GO 

/****** Object:  StoredProcedure [dbo].[SP_MM_ConsultaValidarCantidadAceptacionPedido]    Script Date: 21/04/2021 11:07:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:  Daniel A Cruz  
-- Create date: 24/Marzo/2017  
-- Description: Consultar Validar Cantidad de pedido para poder agregar una Aceptación de Pedido    
-- Author:  Daniel A Cruz  
-- Create date: 01/junio/2018  
-- Description: Agregue validacion de no contar las cantidades de una aceptación con estatus eliminada = 1  
-- =============================================  
CREATE PROCEDURE  [dbo].[SP_MM_ConsultaValidarCantidadAceptacionPedido]   
 -- Add the parameters for the stored procedure here  
    
 @IdPedidoDetalle int,  
 @IdPedido int,  
 @Cantidad FLOAT  
    
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
  
 DECLARE @CantidadSolicitadaPedido FLOAT  = 0  
 DECLARE @CantidadYaAceptada FLOAT  = 0  
 DECLARE @CantidadFaltante FLOAT =0   
  
   
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
  SELECT 'CANTIDAD_INVALIDA,'+CAST( ROUND(ISNULL(@CantidadFaltante,0),5) AS NVARCHAR(MAX))  AS VALIDACION  
    END   
   ELSE   
    BEGIN  
  SELECT 'CANTIDAD_VALIDA,'+CAST(ROUND(ISNULL(@CantidadFaltante,0),5) AS NVARCHAR(MAX))  AS VALIDACION  
    END   
   
END