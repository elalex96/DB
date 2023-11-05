
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_FI_ConsultaCuentasBancarias'
)
    DROP PROCEDURE SP_FI_ConsultaCuentasBancarias
GO
-- =============================================
-- Author:		Daniel AC
-- Create date: 24/05/2017
-- Description:	Obtiene la razon social del subcontratista
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ConsultaCuentasBancarias] 
@IdContratista INT
AS
         BEGIN
             SET NOCOUNT ON;

             SELECT CB.DatoBancarioID,
                    S.RazonSocial,
                    CB.Titular,
                    CB.BancoID,
                    CB.Sucursal,
                    CB.NumeroCuenta,
                    CB.CuentaClave,
                    CB.NumeroTarjeta,
                    CB.IdTipoCuenta,
                    CB.Predeterminado,
                    CB.TipoMonedaID
             FROM CO_Contratista AS C (NOLOCK)
                  INNER JOIN PV_Subcontratista AS S (NOLOCK) 
					ON S.IdSubcontratista = C.IdProveedor
                  INNER JOIN PV_CuentaBancaria AS CB (NOLOCK)
					ON CB.IdProveedor = S.IdSubcontratista
             WHERE C.IdContratista = @IdContratista
			 ORDER BY S.RazonSocial
         END;

