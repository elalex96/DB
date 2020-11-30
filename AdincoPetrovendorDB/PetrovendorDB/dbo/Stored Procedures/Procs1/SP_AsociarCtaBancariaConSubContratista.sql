-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_AsociarCtaBancariaConSubContratista]
@IdCuentaBancaria int,
@IdSubContratista int,
@IdTipoOperacion  int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    update PV_DocumentoCuentaBancaria
	set EstatusAprobacion =  1,
	IsActivo = 0
	where IdCuentaBancaria = @IdCuentaBancaria
	and IdSubContratista =   @IdSubContratista
	and IdTipoOperacion =    @IdTipoOperacion



	insert into PV_CuentaBancariaSubContratista(
	IdCuentaBancaria,
	IdSubcontratista,
    IsActivo
	)
	values
	(
	@IdCuentaBancaria,
	@IdSubContratista,
	1
	)

	select @@IDENTITY



END

