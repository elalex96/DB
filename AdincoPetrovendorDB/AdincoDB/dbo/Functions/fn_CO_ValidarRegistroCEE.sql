--Modificado Por: Daniel Moreno
--Modificado El: 12-05-2022
--Descripción: Se agrega un código de error a cada mensaje, para poderlo controlar desde la pantalla RegistrarGasto.aspx
CREATE FUNCTION [dbo].[fn_CO_ValidarRegistroCEE]
(
	@pIdRegistro int,
	@pIdInstalacion int,
	@pIdPrograma int,
	@pIdFactura int,
	@pMontoRegistro money,
	@pInicioEjecucion datetime,
	@pFinEjecucion datetime,
	@pIdGastoRubro int
)
returns varchar(500)
As

begin

	declare @numReg int,
			@error varchar(500)='',
			@totalGasto FLOAT,
			@totalFactura FLOAT, @idContrato INT;

	select @numReg = count(distinct IdRegistro)
	from CO_Registro 
	where IdRegistro <> @pIdRegistro and
	IdInstalacion = @pIdInstalacion and
	IdPrograma = @pIdPrograma and
	MontoRegistro = @pMontoRegistro and
	InicioEjecucion = @pInicioEjecucion and
	FinEjecucion = @pFinEjecucion and
	IdFactura = @pIdFactura and
	IdGastoRubro = @pIdGastoRubro

	select @totalGasto =  isnull(sum(MontoRegistro)  ,0)
	from CO_Registro r	
	where IdFactura = @pIdFactura and
	IdRegistro <> @pIdRegistro

	select @totalFactura = ISNULL(SubTotal,0)
	from Fi_Factura
	where  IdFactura = @pIdFactura 

	if @numReg > 0
		set @error = 'A0001-Se ha agregado el registro pero ya existe un registro con la misma coincidencia de Instalación, Programa, Factura, Rubro, Monto y Fechas de Ejecución'



	
	if @totalGasto + isnull(@pMontoRegistro,0) > (@totalFactura + 0.1)
	begin
		set @error = 'E0001-No es posible registrar el gasto ya que se excedería el total de la factura. Solo se puede capturar hasta $'+
		cast((isnull(@totalFactura,0) - isnull(@totalGasto,0)) as varchar)+ ' en el monto'
	end


	if exists(
		select 1
		from [CO_PolizasDiarioDetalle] pd
		inner join [dbo].[CO_PolizasDiario] p on p.IdPoliza = pd.IdPoliza
		where idGasto = @pIdRegistro and
		p.Generada = 1
	)
	begin
		set @error =  @error +'|E0002-No es posible modificar el registro ya que hay una póliza generada ligada a este gasto'
	end
	
	---------------------------------------------------------------------------------------------------------
SELECT @idContrato = IdContrato
FROM dbo.FI_Factura
WHERE IdFactura = @pIdFactura

IF (@idContrato IN (   10043,                                    --Jaguar corporativo =1 contrato
                       10018, 10017, 10016, 10015, 10014,        --Jaguar =5 contratos
                       10019, 10020, 10021, 10022, 10023, 10024, --Pantera=6 contratos
                       10052									 --JEP Servicios Corporativo= 1 contrato
                   )
   ) 
BEGIN
    SET @error = ''; --Se añadio para que no devuelva nada en la validación, solo es temporal
END
	---------------------------------------------------------------------------------------------------------
	return @error


end
