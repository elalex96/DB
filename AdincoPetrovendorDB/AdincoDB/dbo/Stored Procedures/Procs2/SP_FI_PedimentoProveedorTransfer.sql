-- =============================================
-- Author:		Manuel CD
-- Create date: 04-12-17
-- Description:	
-- =============================================
--20180731: Reyna Olvera
--Modificado para mostrar los montos de dicha transferencia correctamente
-- =============================================
-- Modificado Por: Neri Garcia
-- Fecha: 11 de Agosto del 2022
-- Detalles: Agregado de NOLOCK, Nombrado de Tablas en select, ajustes de join en orden de llamado de tablas,
--			 eliminación de left join sin uso y eliminación de codigo comentado
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_PedimentoProveedorTransfer]
    @IdContrato INT,
    @IdSubcontratista INT,
    @IdUsuario INT,
    @IdTransfer INT
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
           PV_Subcontratista_SubcontratistaExportador.RazonSocial AS Exportador,
           FI_PedimentoComprobante.AcuseElectronico,
           FI_PedimentoComprobanteDetalle.DescripcionMercancia,
           PV_TipoMoneda.TipoMonedaCorto,
           FI_PedimentoComprobanteDetalle.PrecioUnitario,
           FI_PedimentoComprobanteDetalle.Cantidad,
           AP_Usuario.Nombre AS CreadoPor,
           FI_PedimentoComprobante.CreadoEn,
           FI_TransferFactura.MontoPagado AS MontoPagado
    FROM FI_PedimentoComprobante (NOLOCK)
        INNER JOIN FI_PedimentoComprobanteDetalle
            ON FI_PedimentoComprobante.IdPedimentoComprobante = FI_PedimentoComprobanteDetalle.IdPedimentoComprobante
        LEFT JOIN PV_Subcontratista(NOLOCK)
            ON FI_PedimentoComprobante.IdSubcontratistaImportador = PV_Subcontratista.IdSubcontratista
        LEFT JOIN PV_Subcontratista PV_Subcontratista_SubcontratistaExportador(NOLOCK)
            ON FI_PedimentoComprobante.IdSubcontratistaExportador = PV_Subcontratista_SubcontratistaExportador.IdSubcontratista
        LEFT JOIN PV_TipoMoneda(NOLOCK)
            ON FI_PedimentoComprobante.IdMoneda = PV_TipoMoneda.IdMoneda
        LEFT JOIN AP_Usuario(NOLOCK)
            ON FI_PedimentoComprobante.CreadoPor = AP_Usuario.UsuarioID
        LEFT JOIN FI_ClavesPedimento(NOLOCK)
            ON FI_PedimentoComprobante.ClavePedimento = FI_ClavesPedimento.IdPedimento
        LEFT JOIN FI_TransferFactura(NOLOCK)
            ON FI_PedimentoComprobante.IdPedimentoComprobante = FI_TransferFactura.IdPedimentoComprobante
               AND (
                       FI_TransferFactura.IdTransferFactura IS NULL
                       OR FI_TransferFactura.IdTransfer = @IdTransfer
                   )
    WHERE FI_PedimentoComprobante.CvTipoDocFacturacion = 2
          AND FI_PedimentoComprobante.IdContrato = @IdContrato
          AND FI_PedimentoComprobante.IdSubcontratistaExportador = @IdSubcontratista
    GROUP BY FI_PedimentoComprobante.IdPedimentoComprobante,
             FI_PedimentoComprobante.NumeroPedimento,
             FI_ClavesPedimento.Clave,
             FI_PedimentoComprobante.FolioComprobante,
             FI_PedimentoComprobante.FechaPago,
             FI_PedimentoComprobante.Regimen,
             PV_Subcontratista.RazonSocial,
             FI_PedimentoComprobante.AduanaES,
             PV_Subcontratista_SubcontratistaExportador.RazonSocial,
             FI_PedimentoComprobante.AcuseElectronico,
             FI_PedimentoComprobanteDetalle.DescripcionMercancia,
             PV_TipoMoneda.TipoMonedaCorto,
             FI_PedimentoComprobanteDetalle.PrecioUnitario,
             FI_PedimentoComprobanteDetalle.Cantidad,
             AP_Usuario.Nombre,
             FI_PedimentoComprobante.CreadoEn,
             FI_TransferFactura.MontoPagado
    ORDER BY IdPedimento DESC;
END;