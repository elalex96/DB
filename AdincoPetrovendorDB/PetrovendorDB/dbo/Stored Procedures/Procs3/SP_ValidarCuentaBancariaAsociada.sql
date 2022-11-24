-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ValidarCuentaBancariaAsociada]
@IdCuentaBancaria int,
@IdSubContratista int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @CuentaAsociada int
	set @CuentaAsociada =   (select count(IdCtaBancariaProveedor) 
							from PV_CuentaBancariaSubContratista 
							where IdCuentaBancaria = @IdCuentaBancaria and IdSubcontratista = @IdSubContratista and IsActivo = 1)

	if @CuentaAsociada = 0
	begin
	select 'Cuenta No Asociada' as reponse
	end
	else
	begin
	select 'Cuenta Asociada' as reponse
	end


END

