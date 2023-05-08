-- =============================================
-- Author:		Manuel CD
-- Create date: 25-08-17
-- Description:	
-- =============================================
-- Modificado Por: Neri Garcia
-- Fecha: 11 de Agosto del 2022
-- Detalles: Agregado de NOLOCK, Nombrado de Tablas en select y eliminacion de codigo comentado
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ProveedoresTransfer]
    @IdSubcontratista INT,
    @IdContrato INT,
    @idtran INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    -- 
    IF @idtran <> 0
    BEGIN
        SELECT FI_Transfer.IdTransferencia,
               PV_Subcontratista.RazonSocial,
               PV_Subcontratista.RFC,
               PV_CuentaBancaria.CuentaClave,
               FI_Transfer.ReferenciaBancaria,
               FI_Transfer.FechaPago,
               FI_Transfer.MontoPagado,
               PV_MetodoPago.MetodoPago,
               FI_Transfer.Intereses,
               PV_TipoMoneda.TipoMonedaCorto AS TipoMoneda,
               FI_Transfer.Concepto,
               FI_Transfer.NumeroPolizaContable,
               CASE
                   WHEN FI_Transfer.AWSPDFId IS NULL THEN
                       '¡PDF NO CARGADO!'
                   ELSE
                       'Pdf Cargado'
               END AS 'Comprobante de Pago',
               FI_Transfer.CreadoEn,
               CONVERT(VARCHAR(10), FI_Transfer.ModificadoEn, 103) AS ModificadoEn,
               CO_TipoCambioDiario.TipoCambio
        FROM PV_Subcontratista (NOLOCK)
            JOIN PV_CuentaBancaria (NOLOCK)
                ON PV_Subcontratista.IdSubcontratista = PV_CuentaBancaria.IdProveedor
            JOIN FI_Transfer (NOLOCK)
                ON PV_CuentaBancaria.DatoBancarioID = FI_Transfer.IdCuentaDestino
            JOIN PV_TipoMoneda (NOLOCK)
                ON FI_Transfer.IdMoneda = PV_TipoMoneda.IdMoneda
            JOIN PV_MetodoPago (NOLOCK)
                ON FI_Transfer.IdMetodoPago = PV_MetodoPago.idMetodoPago
            LEFT JOIN CO_TipoCambioDiario (NOLOCK)
                ON FI_Transfer.FechaPago = CO_TipoCambioDiario.Fecha
                   AND FI_Transfer.IdMoneda = CO_TipoCambioDiario.IdMoneda
        WHERE FI_Transfer.IdTransferencia = @idtran
        ORDER BY FI_Transfer.IdTransferencia DESC;
    END;
    ELSE
    BEGIN
        SELECT FI_Transfer.IdTransferencia,
               PV_Subcontratista.RazonSocial,
               PV_Subcontratista.RFC,
               PV_CuentaBancaria.CuentaClave,
               FI_Transfer.ReferenciaBancaria,
               FI_Transfer.FechaPago,
               FI_Transfer.MontoPagado,
               PV_MetodoPago.MetodoPago,
               FI_Transfer.Intereses,
               PV_TipoMoneda.TipoMonedaCorto AS TipoMoneda,
               FI_Transfer.Concepto,
               FI_Transfer.NumeroPolizaContable,
               CASE
                   WHEN FI_Transfer.AWSPDFId IS NULL THEN
                       '¡PDF NO CARGADO!'
                   ELSE
                       'Pdf Cargado'
               END AS 'Comprobante de Pago',
               FI_Transfer.CreadoEn,
               CONVERT(VARCHAR(10), FI_Transfer.ModificadoEn, 103) AS ModificadoEn,
               CO_TipoCambioDiario.TipoCambio
        FROM PV_Subcontratista (NOLOCK)
            JOIN PV_CuentaBancaria (NOLOCK)
                ON PV_Subcontratista.IdSubcontratista = PV_CuentaBancaria.IdProveedor
            JOIN FI_Transfer (NOLOCK)
                ON PV_CuentaBancaria.DatoBancarioID = FI_Transfer.IdCuentaDestino
            JOIN PV_TipoMoneda (NOLOCK)
                ON FI_Transfer.IdMoneda = PV_TipoMoneda.IdMoneda
            JOIN PV_MetodoPago (NOLOCK)
                ON FI_Transfer.IdMetodoPago = PV_MetodoPago.idMetodoPago
            LEFT JOIN dbo.CO_TipoCambioDiario (NOLOCK)
                ON FI_Transfer.FechaPago = CO_TipoCambioDiario.Fecha
                   AND FI_Transfer.IdMoneda = CO_TipoCambioDiario.IdMoneda
        WHERE PV_Subcontratista.IdSubcontratista = @IdSubcontratista
              AND FI_Transfer.IdContrato = @IdContrato
        ORDER BY FI_Transfer.IdTransferencia DESC
    END;
END;