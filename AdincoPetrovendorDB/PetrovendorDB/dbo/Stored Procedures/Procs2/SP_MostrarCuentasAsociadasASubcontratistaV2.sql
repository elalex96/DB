-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE SP_MostrarCuentasAsociadasASubcontratistaV2

@IdCuentaBancaria          int,
@IdProveedorSubcontratista INT,
@IdProveedorContratista INT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		declare @IdCuenta int
	set @IdCuenta = (select count(IdCuentaBancaria) from PV_CuentaBancariaSubContratista 
					where IdCuentaBancaria = @IdCuentaBancaria and IdSubcontratista = @IdProveedorSubcontratista and IsActivo = 1)

	if @IdCuenta > 0

	BEGIN

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

	CREATE TABLE #tempContratista(
	IdRow INT,
	IdContratista INT
	)


		insert into #tempCB select 
    ROW_NUMBER() OVER(ORDER BY IdCtaBancariaProveedor  ASC),
	* from PV_CuentaBancariaSubContratista
	WHERE IsActivo = 1 AND IdSubcontratista = @IdProveedorSubcontratista

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
							WHERE  cbs.IsActivo = 1 AND cbs.IdSubcontratista = @IdProveedorSubcontratista
							)

	while @Contador <= @CountAsociacion
	BEGIN

	DECLARE @IdContratista INT = (
								 SELECT cb.IdProveedor FROM #tempCB tcb 
								 INNER JOIN dbo.PV_CuentaBancaria cb
								 ON tcb.IdCuentaBancaria = cb.DatoBancarioID
								 WHERE tcb.IdSubcontratista = @IdProveedorSubcontratista AND tcb.IdRow = @Contador AND tcb.IdCuentaBancaria = @IdCuentaBancaria
	                             )

	IF (@IdProveedorContratista = @IdContratista)
	BEGIN

	     INSERT into #tempCB2 select 
		 ROW_NUMBER() OVER(ORDER BY IdCtaBancariaProveedor  ASC),
		 * from PV_CuentaBancariaSubContratista 
		 where IdSubcontratista = @IdProveedorSubcontratista
		 AND IdCuentaBancaria = @IdCuentaBancaria and IsActivo = 1

    END 

    --SELECT * FROM #tempCB2

	SET @contador = @contador + 1
    END 


	    SELECT cb.DatoBancarioID, cb.Titular,cb.NumeroCuenta,p.RazonSocial
		from 
		PV_CuentaBancaria cb
		inner join 
		#tempCB2 cbs
		on cb.DatoBancarioID = cbs.IdCuentaBancaria
		inner join S_Proveedor p
		on cbs.IdSubcontratista = p.IdProveedor
		where cbs.IsActivo = 1 



    END
    

END
