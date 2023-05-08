-- =============================================
-- Author:		Manuel CD
-- Create date: 14-09-2017
-- Description:	
-- =============================================
-- Modificado Por:	Neri Garcia
-- Fecha:			16 de Agosto del 2022
-- Descripción:		Eliminación de código comentado, agregado de (NOLOCK), ajustado de orden en los join, se quitan lefts joins posibles
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_PedimentosAsociadasTransfer] 
    @IdTran INT,
    @IdUsuario INT,
    @IdContrato INT
AS
BEGIN
    SET NOCOUNT ON;
    --
    SELECT FI_PedimentoComprobante.IdPedimentoComprobante AS IdPedimento,
           FI_PedimentoComprobante.NumeroPedimento,
           FI_ClavesPedimento.Clave AS ClavePedimento,
           FI_PedimentoComprobante.FolioComprobante,
           FI_PedimentoComprobante.FechaPago,
           FI_PedimentoComprobante.Regimen,
           PV_Subcontratista.RazonSocial AS Importador,
           FI_PedimentoComprobante.AduanaES,
           PV_SubcontratistaExportador.RazonSocial AS Exportador,
           FI_PedimentoComprobante.AcuseElectronico,
           FI_PedimentoComprobanteDetalle.DescripcionMercancia,
           PV_TipoMoneda.TipoMonedaCorto,
           FI_PedimentoComprobanteDetalle.PrecioUnitario,
           FI_PedimentoComprobanteDetalle.Cantidad,
           FI_TransferFactura.MontoPagado
    FROM FI_Transfer (NOLOCK)
        JOIN FI_TransferFactura (NOLOCK)
            ON FI_Transfer.IdTransferencia = @IdTran
               AND FI_Transfer.IdContrato = @IdContrato
               AND FI_Transfer.IdTransferencia = FI_TransferFactura.IdTransfer
        JOIN FI_PedimentoComprobante (NOLOCK)
            ON FI_PedimentoComprobante.CvTipoDocFacturacion = 2
               AND FI_TransferFactura.IdPedimentoComprobante = FI_PedimentoComprobante.IdPedimentoComprobante
        JOIN PV_Subcontratista (NOLOCK)
            ON FI_PedimentoComprobante.IdSubcontratistaImportador = PV_Subcontratista.IdSubcontratista
        JOIN PV_Subcontratista PV_SubcontratistaExportador (NOLOCK)
            ON FI_PedimentoComprobante.IdSubcontratistaExportador = PV_SubcontratistaExportador.IdSubcontratista
        LEFT JOIN FI_PedimentoComprobanteDetalle (NOLOCK)
            ON FI_PedimentoComprobante.IdPedimentoComprobante = FI_PedimentoComprobanteDetalle.IdPedimentoComprobante
        LEFT JOIN FI_ClavesPedimento (NOLOCK)
            ON FI_PedimentoComprobante.ClavePedimento = FI_ClavesPedimento.IdPedimento
        LEFT JOIN PV_TipoMoneda (NOLOCK)
            ON FI_PedimentoComprobante.IdMoneda = PV_TipoMoneda.IdMoneda
    GROUP BY FI_PedimentoComprobante.IdPedimentoComprobante,
             FI_PedimentoComprobante.NumeroPedimento,
             FI_ClavesPedimento.Clave,
             FI_PedimentoComprobante.FolioComprobante,
             FI_PedimentoComprobante.FechaPago,
             FI_PedimentoComprobante.Regimen,
             PV_Subcontratista.RazonSocial,
             FI_PedimentoComprobante.AduanaES,
             PV_SubcontratistaExportador.RazonSocial,
             FI_PedimentoComprobante.AcuseElectronico,
             FI_PedimentoComprobanteDetalle.DescripcionMercancia,
             PV_TipoMoneda.TipoMonedaCorto,
             FI_PedimentoComprobanteDetalle.PrecioUnitario,
             FI_PedimentoComprobanteDetalle.Cantidad,
             FI_TransferFactura.MontoPagado;
END;
