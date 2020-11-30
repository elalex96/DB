-- =============================================
-- Author:		<Jose Roman>
-- Create date: <23/01/2018>
-- Description:	<Se asocia una cuenta bancaria con un subcontratista>
-- =============================================
CREATE PROCEDURE [dbo].[SP_AsociarCuentaBancariaSubcontratista]
	@IdCuentaBancaria int,
	@IdSubcontratista INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

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

