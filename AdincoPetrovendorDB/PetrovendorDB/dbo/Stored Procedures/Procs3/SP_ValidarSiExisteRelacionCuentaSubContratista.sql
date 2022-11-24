-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ValidarSiExisteRelacionCuentaSubContratista]
@IdCuentaBancaria int
--@IdSubContratista int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @ExisteRelacion int 
	set @ExisteRelacion = (select count(IdCtaBancariaProveedor)
						from PV_CuentaBancariaSubContratista
						where IdCuentaBancaria = @IdCuentaBancaria
						and IsActivo = 1)

	if @ExisteRelacion > 0
	begin
	select 'Cuenta Asociada' as response 
	end
	else
	begin
	select 'Cuenta no Asociada' as response 
	end

END

