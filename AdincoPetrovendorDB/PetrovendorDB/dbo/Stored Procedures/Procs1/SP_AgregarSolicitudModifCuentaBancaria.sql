-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_AgregarSolicitudModifCuentaBancaria]
@Documento nvarchar(max),
@IdCuentaBancaria int,
@IdSubContratista int,
@IdTipoOperacion int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if @IdSubContratista > 0 --Asociación datos financieros
	begin 
	insert into PV_DocumentoCuentaBancaria(
	Documento,
    EstatusAprobacion,
    IsActivo,
    FechaRegistro,
    IdCuentaBancaria,
	IdSubContratista,
	IdTipoOperacion
	)
	values(
	@Documento,
	2,
	1,
	getdate(),
	@IdCuentaBancaria,
	@IdSubContratista,
	@IdTipoOperacion
	)
	select @@identity
	end

	else
	begin
	insert into PV_DocumentoCuentaBancaria -- Eliminar/Modificar Cuenta bancaria
	(
	Documento,
    EstatusAprobacion,
    IsActivo,
    FechaRegistro,
    IdCuentaBancaria,
	IdTipoOperacion
	)
	values(
	@Documento,
	2,
	1,
	getdate(),
	@IdCuentaBancaria,
	@IdTipoOperacion
	)
	select @@identity
	end





END

