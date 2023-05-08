-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_WS_ConsultarCuentaBancariaXRFC]
@RFC VARCHAR(30)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT CB.* FROM PV_CuentaBancaria CB
	INNER JOIN S_Proveedor P
	ON CB.IdProveedor = P.IdProveedor
	WHERE RFC = @RFC

END

