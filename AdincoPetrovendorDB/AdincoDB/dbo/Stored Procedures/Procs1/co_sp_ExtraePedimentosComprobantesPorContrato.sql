CREATE PROCEDURE [dbo].[co_sp_ExtraePedimentosComprobantesPorContrato]
    @IdUsuario INT,
    @IdContrato INT
AS
BEGIN
		SELECT 
			FI_PedimentoComprobante.IdPedimentoComprobante,CvTipoDocFacturacion,NumeroPedimento,ClavePedimento,FolioComprobante,
			PV_TipoMoneda.TipoMonedaCorto AS Moneda,
			ISNULL(SUM(   CASE
                      WHEN FI_PedimentoComprobanteDetalle.ImporteTotal IS NOT NULL THEN
                          FI_PedimentoComprobanteDetalle.ImporteTotal
                      ELSE
                          FI_PedimentoComprobanteDetalle.PrecioUnitario
                  END
              ),0) AS ImporteTotal
		FROM
			FI_PedimentoComprobante	
	JOIN FI_PedimentoComprobanteDetalle (NOLOCK)  
            ON FI_PedimentoComprobante.IdPedimentoComprobante = FI_PedimentoComprobanteDetalle.IdPedimentoComprobante
	JOIN PV_TipoMoneda (NOLOCK)
            ON FI_PedimentoComprobante.IdMoneda = PV_TipoMoneda.IdMoneda
		WHERE 
			IdContrato = @IdContrato
		GROUP BY FI_PedimentoComprobante.IdPedimentoComprobante,CvTipoDocFacturacion,NumeroPedimento,ClavePedimento,FolioComprobante,PV_TipoMoneda.TipoMonedaCorto
END;