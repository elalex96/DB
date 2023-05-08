-- =============================================
--20180731: Reyna Olvera
--Modificado para mostrar los montos de dicha transferencia correctamente
-- =============================================
-- Modificado Por: Neri Garcia
-- Fecha: 11 de Agosto del 2022
-- Detalles: Agregado de NOLOCK, Nombrado de Tablas en select, ajustes de join en orden de llamado de tablas,
--			 eliminación de left join sin uso y eliminación de codigo comentado
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ComprobanteProveedorTransfer]
    -- Add the parameters for the stored procedure here
    @IdContrato INT,
    @IdSubcontratista INT,
    @IdUsuario INT,
    @IdTransfer INT
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
           ----------------------------------------------------------------------- 
           /*Se suma el importe total pero se deja con el nombre de PrecioUnitario para no afectar en codigo :
					<dx:GridViewDataTextColumn FieldName="PrecioUnitario" Caption="SubTotal" VisibleIndex="10">
				Cuando no hay importe total si se toma el precio unitario -- DRS 04/08/2020    */

           SUM(   CASE
                      /*el importe total contempla el precion unitario por la cantidad DRS 04/08/2020*/
                      WHEN FI_PedimentoComprobanteDetalle.ImporteTotal IS NOT NULL THEN
                          FI_PedimentoComprobanteDetalle.ImporteTotal
                      ELSE
                          FI_PedimentoComprobanteDetalle.PrecioUnitario
                  END
              ) AS 'PrecioUnitario',
           ----------------------------------------------------------------------------  
           FI_PedimentoComprobanteDetalle.Cantidad,
           /* Esta columna posiblemente no sea necesaria, pero se deja para no afectar en codigo
                  hace practicamente lo mismo que el subtotal*/
           SUM(   CASE
                      WHEN FI_PedimentoComprobanteDetalle.ImporteTotal IS NOT NULL THEN
                          FI_PedimentoComprobanteDetalle.ImporteTotal
                      ELSE
                          FI_PedimentoComprobanteDetalle.PrecioUnitario
                  END
              ) AS 'ImporteTotal',
           -----------------------------------------------------------------------------
           AP_Lista.Nombre AS FormaDePago,
           AP_Usuario.Nombre AS CreadoPor,
           FI_PedimentoComprobante.CreadoEn,
           FI_TransferFactura.MontoPagado AS MontoPagado
    FROM FI_PedimentoComprobante (NOLOCK)
        LEFT JOIN FI_PedimentoComprobanteDetalle (NOLOCK)
            ON FI_PedimentoComprobante.IdPedimentoComprobante = FI_PedimentoComprobanteDetalle.IdPedimentoComprobante
        LEFT JOIN PV_Subcontratista (NOLOCK)
            ON FI_PedimentoComprobante.IdSubcontratistaExportador = PV_Subcontratista.IdSubcontratista
        LEFT JOIN PV_TipoMoneda (NOLOCK)
            ON FI_PedimentoComprobante.IdMoneda = PV_TipoMoneda.IdMoneda
        LEFT JOIN AP_Usuario (NOLOCK)
            ON FI_PedimentoComprobante.CreadoPor = AP_Usuario.UsuarioID
        LEFT JOIN AP_Lista (NOLOCK)
            ON FI_PedimentoComprobante.IdFormaPago = AP_Lista.IdClave
               AND IdGrupo = 10001
        LEFT JOIN PV_MM_MaterialUnidad (NOLOCK)
            ON FI_PedimentoComprobanteDetalle.IdUnidadMedida = PV_MM_MaterialUnidad.IdUnidad
        LEFT JOIN FI_TransferFactura (NOLOCK)
            ON FI_PedimentoComprobante.IdPedimentoComprobante = FI_TransferFactura.IdPedimentoComprobante
               AND (
                       FI_TransferFactura.IdTransferFactura IS NULL
                       OR FI_TransferFactura.IdTransfer = @IdTransfer
                   )
    WHERE FI_PedimentoComprobante.CvTipoDocFacturacion = 3
          AND FI_PedimentoComprobante.IdContrato = @IdContrato
          AND FI_PedimentoComprobante.IdSubcontratistaExportador = @IdSubcontratista
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
             AP_Usuario.Nombre,
             FI_PedimentoComprobante.CreadoEn,
             FI_TransferFactura.MontoPagado
    ORDER BY IdComprobante DESC;
END;
