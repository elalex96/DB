-- =============================================
-- Author:		Manuel CD
-- Create date: 14-09-2017
-- Description:	
-- =============================================
-- Modificado Por:	Neri Garcia
-- Fecha:			16 de Agosto del 2022
-- Descripción:		Eliminación de código comentado, agregado de (NOLOCK), ajustado de orden en los join
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ComprobantesAsociadasTransfer] 
    @IdTran INT,
    @IdUsuario INT,
    @IdContrato INT
AS
BEGIN
    SET NOCOUNT ON;
    --
    SELECT FI_PedimentoComprobante.IdPedimentoComprobante AS IdComprobante,
           FI_PedimentoComprobante.FolioComprobante,
           FI_PedimentoComprobante.FechaPago,
           PV_Subcontratista.RazonSocial AS Exportador,
           FI_PedimentoComprobanteDetalle.NumeroSerieMercancia,
           FI_PedimentoComprobanteDetalle.ClaseBienServicio,
           PV_MM_MaterialUnidad.UMB + ' - ' + PV_MM_MaterialUnidad.Unidad AS UnidadMedida,
           PV_TipoMoneda.TipoMonedaCorto,
           SUM(   CASE
                      WHEN FI_PedimentoComprobanteDetalle.ImporteTotal IS NOT NULL THEN
                          FI_PedimentoComprobanteDetalle.ImporteTotal
                      ELSE
                          FI_PedimentoComprobanteDetalle.PrecioUnitario
                  END
              ) AS 'PrecioUnitario',
           FI_PedimentoComprobanteDetalle.Cantidad,
           SUM(   CASE
                      WHEN FI_PedimentoComprobanteDetalle.ImporteTotal IS NOT NULL THEN
                          FI_PedimentoComprobanteDetalle.ImporteTotal
                      ELSE
                          FI_PedimentoComprobanteDetalle.PrecioUnitario
                  END
              ) AS 'ImporteTotal',
           AP_Lista.Nombre AS FormaDePago,
           FI_TransferFactura.MontoPagado
    FROM FI_Transfer (NOLOCK)
        JOIN FI_TransferFactura (NOLOCK)
            ON FI_Transfer.IdTransferencia = @IdTran
               AND FI_Transfer.IdContrato = @IdContrato
               AND FI_Transfer.IdTransferencia = FI_TransferFactura.IdTransfer
        JOIN FI_PedimentoComprobante (NOLOCK)
            ON FI_PedimentoComprobante.CvTipoDocFacturacion = 3
               AND FI_TransferFactura.IdPedimentoComprobante = FI_PedimentoComprobante.IdPedimentoComprobante
        LEFT JOIN FI_PedimentoComprobanteDetalle (NOLOCK)
            ON FI_PedimentoComprobante.IdPedimentoComprobante = FI_PedimentoComprobanteDetalle.IdPedimentoComprobante
        LEFT JOIN PV_Subcontratista (NOLOCK)
            ON FI_PedimentoComprobante.IdSubcontratistaExportador = PV_Subcontratista.IdSubcontratista
        LEFT JOIN PV_TipoMoneda (NOLOCK)
            ON FI_PedimentoComprobante.IdMoneda = PV_TipoMoneda.IdMoneda
        LEFT JOIN AP_Lista (NOLOCK)
            ON AP_Lista.IdGrupo = 10001
               AND FI_PedimentoComprobante.IdFormaPago = AP_Lista.IdClave
        LEFT JOIN PV_MM_MaterialUnidad (NOLOCK)
            ON FI_PedimentoComprobanteDetalle.IdUnidadMedida = PV_MM_MaterialUnidad.IdUnidad
    GROUP BY FI_PedimentoComprobante.IdPedimentoComprobante,
             FI_PedimentoComprobante.FolioComprobante,
             FI_PedimentoComprobante.FechaPago,
             PV_Subcontratista.RazonSocial,
             FI_PedimentoComprobanteDetalle.NumeroSerieMercancia,
             FI_PedimentoComprobanteDetalle.ClaseBienServicio,
             PV_MM_MaterialUnidad.UMB + ' - ' + PV_MM_MaterialUnidad.Unidad,
             PV_TipoMoneda.TipoMonedaCorto,
             FI_PedimentoComprobanteDetalle.Cantidad,
             AP_Lista.Nombre,
             FI_TransferFactura.MontoPagado;
END;
