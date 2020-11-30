

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_CantadorCuentasFinancieras] 
	-- Add the parameters for the stored procedure here
@IdProveedor int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	  SELECT COUNT(DatoBancarioID) AS CUENTAS_AGREGADAS FROM PV_CuentaBancaria WHERE IdProveedor = @IdProveedor AND IsEliminado = 0
END

