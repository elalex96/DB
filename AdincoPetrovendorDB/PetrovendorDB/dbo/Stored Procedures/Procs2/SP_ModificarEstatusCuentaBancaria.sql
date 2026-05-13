-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ModificarEstatusCuentaBancaria]
@IdCuentaBancaria int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	update PV_DocumentoCuentaBancaria
	set 
	EstatusAprobacion = 1
	where IdCuentaBancaria = @IdCuentaBancaria

	update PV_CuentaBancaria
	set 
	IsEliminado = 1
	where DatoBancarioID = @IdCuentaBancaria


END

