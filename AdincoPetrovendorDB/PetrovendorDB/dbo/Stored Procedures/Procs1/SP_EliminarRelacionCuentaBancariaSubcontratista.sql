-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_EliminarRelacionCuentaBancariaSubcontratista]
@IdCuentaBancaria int,
@IdSubContratista int,
@IdTipoOperacion  int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @Error int

	begin tran
	update PV_CuentaBancariaSubContratista
	set IsActivo = 0
	where 
	IdCuentaBancaria = @IdCuentaBancaria and
    IdSubcontratista = @IdSubContratista

	update PV_DocumentoCuentaBancaria
	set 
	EstatusAprobacion = 1,
	IsActivo = 0
	where
    IdCuentaBancaria = @IdCuentaBancaria and
    IdSubContratista = @IdSubContratista and
    IdTipoOperacion = @IdTipoOperacion

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

