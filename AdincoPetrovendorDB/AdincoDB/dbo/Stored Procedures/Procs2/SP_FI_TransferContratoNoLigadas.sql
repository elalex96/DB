-- =============================================
-- Author:		Manuel CD
-- Create date: 18-06-2018
-- Description:	
-- =============================================
-- =============================================
-- Author:		Marcos Garcia
-- Create date: 16-12-2019
-- Description:	* Agregar Columnas Año y Mes 
--				* Agregar SET LANGUAGE spanish
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_TransferContratoNoLigadas] --3,10002
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@IdUsuario  INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         SET LANGUAGE spanish;
         -- Insert statements for procedure here

         SELECT T.IdTransferencia, 
                CBO.CuentaClave AS 'Cuenta Origen', 
                CBD.CuentaClave AS 'Cuenta Destino', 
                S.RazonSocial, 
                S.RFC, 
                T.ReferenciaBancaria, 
                T.FechaPago, 
                YEAR(T.FechaPago) AS Año, 
                CONCAT(RIGHT('00'+CAST(MONTH(T.FechaPago) AS VARCHAR(2)), 2), ' ', DATENAME(MONTH, T.FechaPago)) AS Mes, 
                T.MontoPagado, 
                T.Intereses, 
                MP.MetodoPago, 
                TM.TipoMonedaCorto AS TipoMoneda, 
                T.Concepto, 
                T.NumeroPolizaContable,
                CASE
                    WHEN(T.PDF LIKE ''
                         OR T.PDF IS NULL)
                        AND t.AWSPDFId IS NULL
                    THEN '¡PDF NO CARGADO!'
                    ELSE 'Pdf Cargado'
                END AS 'Comprobante de Pago', 
                U.Nombre AS CreadoPor, 
                T.CreadoEn AS 'Fecha Registro', 
                UM.Nombre AS ModificadoPor, 
                T.ModificadoEn AS 'Fecha Modificado'
         FROM FI_Transfer AS T
              LEFT JOIN PV_CuentaBancaria AS CBD ON CBD.DatoBancarioID = T.IdCuentaDestino
              LEFT JOIN PV_CuentaBancaria AS CBO ON CBO.DatoBancarioID = T.IdCuentaOrigen
              LEFT JOIN PV_Subcontratista AS S ON CBD.IdProveedor = S.IdSubcontratista
              JOIN PV_TipoMoneda AS TM ON T.IdMoneda = TM.IdMoneda
              JOIN PV_MetodoPago AS MP ON T.IdMetodoPago = MP.idMetodoPago
              LEFT JOIN AP_Usuario AS U ON T.CreadoPor = U.UsuarioID
              LEFT JOIN AP_Usuario AS UM ON T.ModificadoPor = UM.UsuarioID
              LEFT JOIN dbo.FI_TransferFactura TF ON TF.IdTransfer = T.IdTransferencia
         WHERE T.IdContrato = @IdContrato
               AND TF.IdTransfer IS NULL
         GROUP BY YEAR(T.FechaPago), 
                  CONCAT(RIGHT('00'+CAST(MONTH(T.FechaPago) AS VARCHAR(2)), 2), ' ', DATENAME(MONTH, T.FechaPago)),
                  CASE
                      WHEN(T.PDF LIKE ''
                           OR T.PDF IS NULL)
                          AND T.AWSPDFId IS NULL
                      THEN '¡PDF NO CARGADO!'
                      ELSE 'Pdf Cargado'
                  END, 
                  T.IdTransferencia, 
                  CBO.CuentaClave, 
                  CBD.CuentaClave, 
                  S.RazonSocial, 
                  S.RFC, 
                  T.ReferenciaBancaria, 
                  T.FechaPago, 
                  T.MontoPagado, 
                  T.Intereses, 
                  MP.MetodoPago, 
                  TM.TipoMonedaCorto, 
                  T.Concepto, 
                  T.NumeroPolizaContable, 
                  U.Nombre, 
                  T.CreadoEn, 
                  UM.Nombre, 
                  T.ModificadoEn
         ORDER BY T.IdTransferencia DESC;
     END;