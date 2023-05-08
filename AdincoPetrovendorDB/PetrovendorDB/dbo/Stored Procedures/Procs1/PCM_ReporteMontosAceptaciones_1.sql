
CREATE PROCEDURE [PCM_ReporteMontosAceptaciones_1]
AS BEGIN

	DELETE  PCM_ReporteMontosAceptaciones

INSERT INTO PCM_ReporteMontosAceptaciones 

SELECT PS.IdPedido, 
       PD.IdPedidoDetalle, 
       M.DescripcionLarga, 
       PD.Cantidad, 
       PD.PrecioUnitario, 
       PD.Subtotal,
       CASE PD.IdMoneda
           WHEN 1
           THEN 'MNX'
           WHEN 2
           THEN 'USD'
       END AS MonedaPedido, 
	   CASE PD.IdMoneda
           WHEN 1
		   THEN
            [dbo].[FN_PesosDolaresTipoCambio](PD.Subtotal, P.CreadoEl)
           WHEN 2
           THEN PD.Subtotal
       END AS MontoPedidoUSD, 
	  SUM(APD.Cantidad) AS CantidadAceptada,
	  SUM(APD.Cantidad) * PD.PrecioUnitario AS MontoAceptado,
  CASE PD.IdMoneda
           WHEN 1
           THEN 'MNX'
           WHEN 2
           THEN 'USD'
       END AS MonedaPedido_Aceptado, 
	    PD.Cantidad - SUM(APD.Cantidad) AS Diferencia,
		(PD.Cantidad - SUM(APD.Cantidad)) * PD.PrecioUnitario AS Monto_Por_aceptar,

		CASE PD.IdMoneda
           WHEN 1
		   THEN
            [dbo].[FN_PesosDolaresTipoCambio]((PD.Cantidad - SUM(APD.Cantidad)) * PD.PrecioUnitario, P.CreadoEl)
           WHEN 2
           THEN PD.Subtotal
       END AS Monto_PorAceptar_USD, 
  P.CreadoEl,
  CA.TipoCambio
FROM MM_pedido P
     INNER JOIN MM_pedidos PS ON P.IdPedido = PS.IdIdentificador
     INNER JOIN MM_PedidoDetalle PD ON P.IdPedido = PD.IdPedido
     INNER JOIN MM_Material M ON PD.IdMaterial = M.IdMaterial
	 INNER JOIN MM_AceptacionPedidodetalle APD ON PD.IdPedidoDetalle = APD.IdPedidoDetalle
	 INNER JOIN MM_AceptacionPedido AP ON APD.IdAceptacionPedido = AP.IdAceptacionPedido
	  LEFT JOIN Adinco..CO_TipoCambioDiario CA ON CA.IdMoneda = P.IdMoneda
														AND DAY(CA.Fecha) = DAY(P.CreadoEl)
                                                               AND MONTH(CA.Fecha) = MONTH(P.CreadoEl)
                                                               AND YEAR(CA.Fecha) = YEAR(P.CreadoEl)
WHERE 
P.idContrato = 10036 AND
  ISNULL(P.IdEstatusEliminado, 0) <> 1
      AND ISNULL(AP.IdEstatusEliminado, 0) <> 1
      AND ISNULL(PD.IdEstatusEliminado, 0) <> 1
group by APD.IdPedidoDetalle,
	   PS.IdPedido, 
       PD.IdPedidoDetalle, 
       M.DescripcionLarga, 
       PD.Cantidad, 
       PD.PrecioUnitario, 
       PD.Subtotal,
       P.CreadoEl,
	   PD.IdMoneda,
	   CA.TipoCambio

END
