USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_FI_TransferContratoNoLigadas'
)
    DROP PROCEDURE SP_FI_TransferContratoNoLigadas; 
GO
/****** Object:  StoredProcedure [dbo].[SP_FI_TransferContratoNoLigadas]    Script Date: 11/01/2023 12:19:50 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
-- =============================================
-- Author:		Daniel AC
-- Create date: 11/01/2023
-- Description: Se agrega nolocks 
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_TransferContratoNoLigadas]
-- Add the parameters for the stored procedure here
@IdProveedor INT
AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @Rfc NVARCHAR(100)= '';
        SELECT @Rfc = RFC
        FROM dbo.S_Proveedor (NOLOCK)
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
        FROM Adinco.dbo.FI_Transfer AS T (NOLOCK)
			JOIN Adinco.dbo.PV_TipoMoneda AS TM (NOLOCK) ON T.IdMoneda = TM.IdMoneda
            JOIN Adinco.dbo.PV_MetodoPago AS MP (NOLOCK) ON T.IdMetodoPago = MP.IdMetodoPago
            JOIN Adinco.dbo.PV_CuentaBancaria AS CBD (NOLOCK) ON T.IdCuentaDestino = CBD.DatoBancarioID 
            JOIN Adinco.dbo.PV_CuentaBancaria AS CBO (NOLOCK) ON T.IdCuentaOrigen = CBO.DatoBancarioID 
            JOIN Adinco.dbo.PV_Subcontratista AS S (NOLOCK) ON CBD.IdProveedor = S.IdSubcontratista             
             LEFT JOIN Adinco.dbo.AP_Usuario AS U (NOLOCK) ON T.CreadoPor = U.UsuarioID
             LEFT JOIN Adinco.dbo.AP_Usuario AS UM (NOLOCK) ON T.ModificadoPor = UM.UsuarioID
             LEFT JOIN Adinco.dbo.FI_TransferFactura TF (NOLOCK) ON T.IdTransferencia = TF.IdTransfer
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