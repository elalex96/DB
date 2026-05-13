-- =============================================
-- Author:		Daniel AC
-- Create date: 24/05/2017
-- Description:	Obtiene la razon social del subcontratista
-- =============================================
create PROCEDURE [dbo].[SP_FI_ConsultaCuentasBancariasProveedores] 
	-- Add the parameters for the stored procedure here
	--@IdContratista int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT CB.DatoBancarioID, S.RazonSocial, CB.Titular, CB.BancoID,  CB.Sucursal, 
	CB.NumeroCuenta, CB.CuentaClave,CB.NumeroTarjeta, CB.IdTipoCuenta, CB.Predeterminado, CB.TipoMonedaID
	FROM PV_Subcontratista AS S
	INNER JOIN PV_CuentaBancaria AS CB ON CB.IdProveedor = S.IdSubcontratista


END


