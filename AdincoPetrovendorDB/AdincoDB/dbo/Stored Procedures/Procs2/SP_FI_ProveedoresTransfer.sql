-- =============================================
-- Author:		Manuel CD
-- Create date: 25-08-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ProveedoresTransfer] 
-- Add the parameters for the stored procedure here
@IdSubcontratista INT, 
@IdContrato       INT, 
@idtran           INT = 0
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         -- Insert statements for procedure here
         IF @idtran <> 0
             BEGIN
                 SELECT T.IdTransferencia, 
                        S.RazonSocial, 
                        S.RFC, 
                        CB.CuentaClave, 
                        T.ReferenciaBancaria, 
                        T.FechaPago, 
                        T.MontoPagado, 
                        MP.MetodoPago, 
                        T.Intereses, 
                        TM.TipoMonedaCorto AS TipoMoneda, 
                        T.Concepto, 
                        T.NumeroPolizaContable,
                        --CASE
                        --    WHEN T.PDF LIKE ''
                        --         OR T.PDF IS NULL
                        --    THEN '¡PDF NO CARGADO!'
                        --    ELSE 'Pdf Cargado'
                        --END AS 'Comprobante de Pago', 
                        CASE
                            WHEN T.AWSPDFId IS NULL
                            THEN '¡PDF NO CARGADO!'
                            ELSE 'Pdf Cargado'
                        END AS 'Comprobante de Pago', 
                        T.CreadoEn, 
                        CONVERT(VARCHAR(10), T.ModificadoEn, 103) AS ModificadoEn, 
                        TCD.TipoCambio
                 FROM PV_Subcontratista AS S
                      JOIN PV_CuentaBancaria AS CB ON S.IdSubcontratista = CB.IdProveedor
                      JOIN FI_Transfer AS T ON CB.DatoBancarioID = T.IdCuentaDestino
                      JOIN PV_TipoMoneda AS TM ON T.IdMoneda = TM.IdMoneda
                      JOIN PV_MetodoPago AS MP ON T.IdMetodoPago = MP.idMetodoPago
                      LEFT JOIN dbo.CO_TipoCambioDiario AS TCD ON T.FechaPago = TCD.Fecha
                                                                  AND T.IdMoneda = TCD.IdMoneda
                 WHERE T.IdTransferencia = @idtran
                 ORDER BY T.IdTransferencia DESC;
             END;
             ELSE
             BEGIN
                 SELECT T.IdTransferencia, 
                        S.RazonSocial, 
                        S.RFC, 
                        CB.CuentaClave, 
                        T.ReferenciaBancaria, 
                        T.FechaPago, 
                        T.MontoPagado, 
                        MP.MetodoPago, 
                        T.Intereses, 
                        TM.TipoMonedaCorto AS TipoMoneda, 
                        T.Concepto, 
                        T.NumeroPolizaContable,
                        --CASE
                        --    WHEN T.PDF LIKE ''
                        --         OR T.PDF IS NULL
                        --    THEN '¡PDF NO CARGADO!'
                        --    ELSE 'Pdf Cargado'
                        --END AS 'Comprobante de Pago',
                        CASE
                            WHEN T.AWSPDFId IS NULL
                            THEN '¡PDF NO CARGADO!'
                            ELSE 'Pdf Cargado'
                        END AS 'Comprobante de Pago', 
                        T.CreadoEn, 
                        CONVERT(VARCHAR(10), T.ModificadoEn, 103) AS ModificadoEn, 
                        TCD.TipoCambio
                 FROM PV_Subcontratista AS S
                      JOIN PV_CuentaBancaria AS CB ON S.IdSubcontratista = CB.IdProveedor
                      JOIN FI_Transfer AS T ON CB.DatoBancarioID = T.IdCuentaDestino
                      JOIN PV_TipoMoneda AS TM ON T.IdMoneda = TM.IdMoneda
                      JOIN PV_MetodoPago AS MP ON T.IdMetodoPago = MP.idMetodoPago
                      LEFT JOIN dbo.CO_TipoCambioDiario AS TCD ON T.FechaPago = TCD.Fecha
                                                                  AND T.IdMoneda = TCD.IdMoneda
                 WHERE S.IdSubcontratista = @IdSubcontratista
                       AND T.IdContrato = @IdContrato
                 ORDER BY T.IdTransferencia DESC
             END;
                 --EXEC SP_FI_ProveedoresTransfer 10016,10003
     END;