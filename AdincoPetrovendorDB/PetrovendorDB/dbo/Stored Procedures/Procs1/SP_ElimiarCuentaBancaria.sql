-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ElimiarCuentaBancaria]
@IdCuentaBancaria int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	   declare @Error int

	begin tran
	update PV_CuentaBancaria 
	set IsEliminado = 1
	where DatoBancarioID = @IdCuentaBancaria

	set @Error = @@ERROR
	if @Error<>0 goto TratarError
	commit tran

	TratarError:
	if @Error<>0
	begin
	select @@ERROR
	rollback tran
	end

	select 'success'

END

