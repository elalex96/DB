-- =============================================
-- Author:      Manuel CD
-- Create date: 18-06-2018
-- Description: 
-- =============================================
-- Author:      Pedro Acuña
-- Create date: 15/07/2019
-- Description: se adecua para el uso en petrovendor
-- Author:    Daniel AC
-- Create date: 13/12/2019
-- Description: se adecua para el uso los comprobantes en s3
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_TransferContratoNoLigadas]
-- Add the parameters for the stored procedure here
@IdProveedor INT
AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @Rfc NVARCHAR(100)= '';
        SELECT @Rfc = RFC
        FROM dbo.S_Proveedor
        WHERE IdProveedor = @IdProveedor;
        SELECT T.IdTransferencia, 
               CBO.CuentaClave AS 'Cuenta Origen', 
               CBD.CuentaClave AS 'Cuenta Destino', 
               S.RazonSocial, 
               S.RFC, 
               T.ReferenciaBancaria, 
               T.FechaPago, 
               T.MontoPagado, 
               T.Intereses, 
               MP.MetodoPago, 
               TM.TipoMonedaCorto AS TipoMoneda, 
               T.Concepto, 
               T.NumeroPolizaContable,
               CASE
                   WHEN T.AWSPDFId IS NULL
                   THEN ''
                   ELSE 'PDF Cargado'
               END AS 'ComprobantedePago', 
               U.Nombre AS CreadoPor, 
               T.CreadoEn AS 'Fecha Registro', 
               UM.Nombre AS ModificadoPor, 
               T.ModificadoEn AS 'Fecha Modificado'
        FROM Adinco.dbo.FI_Transfer AS T
             LEFT JOIN Adinco.dbo.PV_CuentaBancaria AS CBD ON CBD.DatoBancarioID = T.IdCuentaDestino
             LEFT JOIN Adinco.dbo.PV_CuentaBancaria AS CBO ON CBO.DatoBancarioID = T.IdCuentaOrigen
             LEFT JOIN Adinco.dbo.PV_Subcontratista AS S ON CBD.IdProveedor = S.IdSubcontratista
             JOIN Adinco.dbo.PV_TipoMoneda AS TM ON T.IdMoneda = TM.IdMoneda
             JOIN Adinco.dbo.PV_MetodoPago AS MP ON T.IdMetodoPago = MP.IdMetodoPago
             LEFT JOIN Adinco.dbo.AP_Usuario AS U ON T.CreadoPor = U.UsuarioID
             LEFT JOIN Adinco.dbo.AP_Usuario AS UM ON T.ModificadoPor = UM.UsuarioID
             LEFT JOIN Adinco.dbo.FI_TransferFactura TF ON TF.IdTransfer = T.IdTransferencia
        WHERE S.RFC = @Rfc
              AND TF.IdTransfer IS NULL
        GROUP BY T.IdTransferencia, 
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
                 T.PDF, 
                 U.Nombre, 
                 T.CreadoEn, 
                 UM.Nombre, 
                 T.ModificadoEn, 
                 t.AWSPDFId
        ORDER BY T.FechaPago DESC;
    END;
