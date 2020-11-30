-- =============================================
-- Author:		Manuel CD
-- Create date: 01-09-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ConsultaRegistroTransferEdicion] 
-- Add the parameters for the stored procedure here
@IdTran     INT, 
@IdContrato INT = 0, 
@IdUsuario  INT = 0
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here

         SELECT S.IdSubcontratista, 
                T.IdMetodoPago, 
                T.IdCuentaOrigen, 
                T.IdCuentaDestino, 
                T.ReferenciaBancaria, 
                T.FechaPago, 
                T.MontoPagado, 
                ISNULL(T.Intereses, 0) AS Intereses, 
                T.IdMoneda, 
                T.Concepto, 
                T.NumeroPolizaContable,
                CASE
                    WHEN T.IdFormaPago = 1
                    THEN 0
                    WHEN T.IdFormaPago = 2
                    THEN 1
                    ELSE 0
                END AS IdFormaPago, 
                ISNULL(TF.CvTipoDocFacturacion, 1) AS CvTipoDocFacturacion
         FROM PV_Subcontratista AS S
              LEFT JOIN PV_CuentaBancaria AS CB ON S.IdSubcontratista = CB.IdProveedor
              LEFT JOIN FI_Transfer AS T ON CB.DatoBancarioID = T.IdCuentaDestino
              LEFT JOIN dbo.FI_TransferFactura TF ON TF.IdTransfer = T.IdTransferencia
              JOIN PV_TipoMoneda AS TM ON T.IdMoneda = TM.IdMoneda
              JOIN PV_MetodoPago AS MP ON T.IdMetodoPago = MP.idMetodoPago
         WHERE T.IdTransferencia = @IdTran
               AND T.IdContrato = @IdContrato
         GROUP BY S.IdSubcontratista, 
                  T.IdMetodoPago, 
                  T.IdCuentaOrigen, 
                  T.IdCuentaDestino, 
                  T.ReferenciaBancaria, 
                  T.FechaPago, 
                  T.MontoPagado, 
                  ISNULL(T.Intereses, 0), 
                  T.IdMoneda, 
                  T.Concepto, 
                  T.NumeroPolizaContable,
                  CASE
                      WHEN T.IdFormaPago = 1
                      THEN 0
                      WHEN T.IdFormaPago = 2
                      THEN 1
                      ELSE 0
                  END, 
                  ISNULL(TF.CvTipoDocFacturacion, 1);

         --EXEC SP_FI_ConsultaRegistroTransferEdicion 650
     END;