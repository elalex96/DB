-- =============================================
-- Author:		Manuel CD
-- Create date: 01-09-17
-- Description:	
-- =============================================
-- Modificado Por: Neri Garcia
-- Fecha: 11 de Agosto del 2022
-- Detalles: Agregado de NOLOCK, Nombrado de Tablas en select, ajustes de join en orden de llamado de tablas y eliminación de codigo comentado
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ConsultaRegistroTransferEdicion]
    -- Add the parameters for the stored procedure here
    @IdTran INT,
    @IdContrato INT = 0,
    @IdUsuario INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    -- 
    SELECT PV_Subcontratista.IdSubcontratista,
           FI_Transfer.IdMetodoPago,
           FI_Transfer.IdCuentaOrigen,
           FI_Transfer.IdCuentaDestino,
           FI_Transfer.ReferenciaBancaria,
           FI_Transfer.FechaPago,
           FI_Transfer.MontoPagado,
           ISNULL(FI_Transfer.Intereses, 0) AS Intereses,
           FI_Transfer.IdMoneda,
           FI_Transfer.Concepto,
           FI_Transfer.NumeroPolizaContable,
           CASE
               WHEN FI_Transfer.IdFormaPago = 1 THEN
                   0
               WHEN FI_Transfer.IdFormaPago = 2 THEN
                   1
               ELSE
                   0
           END AS IdFormaPago,
           ISNULL(FI_TransferFactura.CvTipoDocFacturacion, 1) AS CvTipoDocFacturacion
    FROM PV_Subcontratista (NOLOCK)
        LEFT JOIN PV_CuentaBancaria (NOLOCK)
            ON PV_Subcontratista.IdSubcontratista = PV_CuentaBancaria.IdProveedor
        LEFT JOIN FI_Transfer (NOLOCK)
            ON PV_CuentaBancaria.DatoBancarioID = FI_Transfer.IdCuentaDestino
        LEFT JOIN FI_TransferFactura (NOLOCK)
            ON FI_TransferFactura.IdTransfer = FI_Transfer.IdTransferencia
        JOIN PV_TipoMoneda (NOLOCK)
            ON FI_Transfer.IdMoneda = PV_TipoMoneda.IdMoneda
        JOIN PV_MetodoPago (NOLOCK)
            ON FI_Transfer.IdMetodoPago = PV_MetodoPago.idMetodoPago
    WHERE FI_Transfer.IdTransferencia = @IdTran
          AND FI_Transfer.IdContrato = @IdContrato
    GROUP BY PV_Subcontratista.IdSubcontratista,
             FI_Transfer.IdMetodoPago,
             FI_Transfer.IdCuentaOrigen,
             FI_Transfer.IdCuentaDestino,
             FI_Transfer.ReferenciaBancaria,
             FI_Transfer.FechaPago,
             FI_Transfer.MontoPagado,
             ISNULL(FI_Transfer.Intereses, 0),
             FI_Transfer.IdMoneda,
             FI_Transfer.Concepto,
             FI_Transfer.NumeroPolizaContable,
             CASE
                 WHEN FI_Transfer.IdFormaPago = 1 THEN
                     0
                 WHEN FI_Transfer.IdFormaPago = 2 THEN
                     1
                 ELSE
                     0
             END,
             ISNULL(FI_TransferFactura.CvTipoDocFacturacion, 1);
END;