-- =============================================
-- Author:		Daniel AC
-- Create date: 24/05/2017
-- Description:	Obtiene la razon social del subcontratista
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ConsultaCuentasBancarias] 
	-- Add the parameters for the stored procedure here
@IdContratista INT
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;

    -- Insert statements for procedure here
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
             FROM CO_Contratista AS C
                  INNER JOIN PV_Subcontratista AS S ON S.IdSubcontratista = C.IdProveedor
                  INNER JOIN PV_CuentaBancaria AS CB ON CB.IdProveedor = S.IdSubcontratista
             WHERE C.IdContratista = @IdContratista;
         END;


