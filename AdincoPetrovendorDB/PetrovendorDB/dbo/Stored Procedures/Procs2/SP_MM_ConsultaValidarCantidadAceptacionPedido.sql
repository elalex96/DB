USE [Petrovendor]
GO
IF OBJECT_ID('Petrovendor..SP_MM_ConsultaValidarCantidadAceptacionPedido') IS NOT NULL
BEGIN
DROP PROCEDURE SP_MM_ConsultaValidarCantidadAceptacionPedido;
END
GO
-- =============================================
-- Author:  Daniel A Cruz
-- Create date: 24/Marzo/2017
-- Description: Consultar Validar Cantidad de pedido para poder agregar una Aceptación de Pedido
-- =============================================
-- Author:  Daniel A Cruz
-- Create date: 01/junio/2018
-- Description: Agregue validacion de no contar las cantidades de una aceptacion con estatus eliminada = 1
-- =============================================
-- Author:  Alexander Gomez
-- Create date: 28/Octubre/2025
-- Description: se aplica redondeo a 5 digitos decimales
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaValidarCantidadAceptacionPedido]
    -- Add the parameters for the stored procedure here
    @IdPedidoDetalle int,
    @IdPedido int,
    @Cantidad DECIMAL(18, 5)  -- Este tipo ya era correcto
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @CantidadSolicitadaPedido DECIMAL(18, 5) = 0
    DECLARE @CantidadYaAceptada DECIMAL(18, 5) = 0
    DECLARE @CantidadFaltante DECIMAL(18, 5) = 0

    SET @CantidadYaAceptada =
    (
        SELECT SUM(ISNULL(APD.Cantidad,0)) AS CantidadYaAceptada
        FROM MM_AceptacionPedidoDetalle AS APD
        INNER JOIN MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
        INNER JOIN MM_Pedido AS P ON P.IdPedido = AP.IdPedido
        INNER JOIN MM_PedidoDetalle AS PD ON PD.IdPedidoDetalle = APD.IdPedidoDetalle
        WHERE P.IdPedido = @IdPedido AND PD.IdPedidoDetalle = @IdPedidoDetalle AND ISNULL(AP.IdEstatusEliminado,0) <> 1
    )
    /*SOLO SE TOMA EN CUENTA LAS CANTIDADES DE LAS ACEPTACIONES DE PEDIDO QUE NO ESTEN ELIMINADAS <> 1*/

    SET @CantidadSolicitadaPedido =
    (
        SELECT PD.Cantidad
        FROM MM_PedidoDetalle AS PD
        WHERE PD.IdPedidoDetalle = @IdPedidoDetalle AND PD.IdPedido = @IdPedido
    )

    -- Se redondea el resultado final a 5 decimales para asegurar consistencia.
    SET @CantidadFaltante = ROUND(ISNULL(@CantidadSolicitadaPedido,0) - ISNULL(@CantidadYaAceptada,0), 5)

    IF @CantidadFaltante < 0
        SET @CantidadFaltante = 0

    -- Ya no se necesita el ROUND() aquí porque @CantidadFaltante ya fue redondeada.
    IF @Cantidad > @CantidadFaltante
    BEGIN
        SELECT 'CANTIDAD_INVALIDA,'+CAST(ISNULL(@CantidadFaltante,0) AS NVARCHAR(MAX)) AS VALIDACION
    END
    ELSE
    BEGIN
        SELECT 'CANTIDAD_VALIDA,'+CAST(ISNULL(@CantidadFaltante,0) AS NVARCHAR(MAX)) AS VALIDACION
    END

END