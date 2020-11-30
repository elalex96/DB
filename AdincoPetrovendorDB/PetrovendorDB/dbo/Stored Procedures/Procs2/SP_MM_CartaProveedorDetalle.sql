-- =============================================
-- Author:		Manuel Cruz
-- Create date: 27-06-17
-- Description:	Agregue validación para tipo de cambio, si no hay registro en MM_TipoCambioPedido 
-- busca el tipo de cambio de la fecha de creación del pedido
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_CartaProveedorDetalle]
    -- Add the parameters for the stored procedure here
    @IdPedido INT,
	/*--------------------
    parametros contrato
  --------------------*/
    @IdContrato    INT,
    @IdUsuario     INT,
    @FechaRegistro DATETIME
  /*--------------------
  --------------------*/ 
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    DECLARE @IdMonedaNacional INT = 1;   
    -- Insert statements for procedure here 



    SELECT ISNULL(BSA.Codigo, 'NO CONTENIDO') AS CodigoCatalogo,
           M.DescripcionCorta,
           ROUND(APD.PCN, 3) AS PorcentajeContenidoNacional,
           ---  ROUND((APD.Cantidad + APD.Excedente) * PD.PrecioUnitario, 2) AS MontoFacturado,
           CASE
               WHEN PD.IdMoneda <> @IdMonedaNacional THEN
                   ROUND(
                            (ISNULL(
                             (
                                 SELECT TC.TipoCambio
                                 FROM Adinco.dbo.CO_TipoCambioDiario TC
                                 WHERE DAY(PTC.FechaTipoCambio) = DAY(TC.Fecha)
                                       AND MONTH(PTC.FechaTipoCambio) = MONTH(TC.Fecha)
                                       AND YEAR(PTC.FechaTipoCambio) = MONTH(TC.Fecha)
                                       AND TC.IdMoneda =@IdMonedaNacional
                             ),
                             (
                                 SELECT TipoCambio FROM dbo.GetTipoCambioActual(@IdMonedaNacional, P.Creadoel)
                             )
                                   ) * PD.PrecioUnitario
                            ) * (APD.Cantidad + APD.Excedente),
                            2
                        )
               ELSE
                   ROUND((APD.Cantidad + APD.Excedente) * PD.PrecioUnitario, 2)
           END AS MontoFacturado
    FROM MM_AceptacionPedidoDetalle AS APD
        JOIN MM_AceptacionPedido AS AP
            ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
        JOIN MM_PedidoDetalle AS PD
            ON PD.IdPedidoDetalle = APD.IdPedidoDetalle
        JOIN MM_Material M
            ON PD.IdMaterialVendedor = M.IdMaterial
        LEFT JOIN dbo.MM_BS_Actividad AS BSA
            ON BSA.IdActividad = M.IdBienServicioEconomia
        LEFT JOIN dbo.MM_PedidoTipoCambio AS PTC
            ON PTC.IdPedido = PD.IdPedido
        INNER JOIN MM_Pedido AS P
            ON P.IdPedido = PD.IdPedido
    WHERE AP.IdAceptacionPedido = @IdPedido;


END;


