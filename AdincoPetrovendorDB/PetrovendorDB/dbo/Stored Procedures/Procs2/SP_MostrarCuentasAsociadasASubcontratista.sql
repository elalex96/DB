-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MostrarCuentasAsociadasASubcontratista]
@IdCuentaBancaria          int,
@IdProveedorSubcontratista int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @IdCuenta int
	set @IdCuenta = (select count(IdCuentaBancaria) from PV_CuentaBancariaSubContratista 
					where IdCuentaBancaria = @IdCuentaBancaria and IdSubcontratista = @IdProveedorSubcontratista and IsActivo = 1)

	if @IdCuenta > 0

	begin
	
	create table #tempCB(
	IdRow int,
	IdCtaBancariaProveedor int,
    IdCuentaBancaria int,
    IdSubcontratista int,
	IsActivo bit
	)

	create table #tempCB2(
    IdRow int,
	IdCtaBancariaProveedor int,
    IdCuentaBancaria int,
    IdSubcontratista int,
	IsActivo bit
	)

	insert into #tempCB select 
    ROW_NUMBER() OVER(ORDER BY IdCtaBancariaProveedor  ASC),
	* from PV_CuentaBancariaSubContratista
	


	declare @contador int
	set @contador = 1
	declare @CountAsociacion int
	set @CountAsociacion = (
							select count(*)
							from 
							PV_CuentaBancaria cb
							inner join 
							PV_CuentaBancariaSubContratista cbs
							on cb.DatoBancarioID = cbs.IdCuentaBancaria
							)

	while @Contador <= @CountAsociacion
	begin
	declare @SubContratista int
	set @SubContratista = (select IdSubcontratista from #tempCB where IdRow = @Contador and IsActivo = 1)

	if @SubContratista = @IdProveedorSubcontratista
	begin

	declare @Cuenta int
	set @Cuenta = (select IdCuentaBancaria from #tempCB where IdRow = @Contador )


	insert into #tempCB2 select 
    ROW_NUMBER() OVER(ORDER BY IdCtaBancariaProveedor  ASC),
	* from PV_CuentaBancariaSubContratista where IdSubcontratista = @SubContratista
	and IdCuentaBancaria = @Cuenta and IsActivo = 1

	end

	set @Contador = @Contador + 1
	end

		select cb.DatoBancarioID, cb.Titular,cb.NumeroCuenta,p.RazonSocial
		from 
		PV_CuentaBancaria cb
		inner join 
		#tempCB2 cbs
		on cb.DatoBancarioID = cbs.IdCuentaBancaria
		inner join S_Proveedor p
		on cbs.IdSubcontratista = p.IdProveedor
		where cbs.IsActivo = 1 
	 
	end

	

END

