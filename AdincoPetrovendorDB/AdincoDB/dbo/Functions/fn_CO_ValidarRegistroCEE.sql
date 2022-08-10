-- =============================================
--Modificado Por: Daniel Moreno
--Modificado El: 12-05-2022
--Descripción: Se agrega un código de error a cada mensaje, para poderlo controlar desde la pantalla RegistrarGasto.aspx
-- =============================================
-- Modificado Por:			Neri del Angel
-- Fecha de Modificación:	09 de Agosto del 2022
-- Descripción:				Se agregan NOLOCK y la llamada de columnas con nombre especifico de la tabla durante su llamado.
-- =============================================
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
RETURNS VARCHAR(500)
AS
BEGIN

    DECLARE @numReg INT,
            @error VARCHAR(500) = '',
            @totalGasto FLOAT,
            @totalFactura FLOAT,
            @idContrato INT;

    SELECT @numReg = COUNT(DISTINCT CO_Registro.IdRegistro)
    FROM CO_Registro (NOLOCK) 
    WHERE CO_Registro.IdRegistro <> @pIdRegistro
          AND CO_Registro.IdInstalacion = @pIdInstalacion
          AND CO_Registro.IdPrograma = @pIdPrograma
          AND CO_Registro.MontoRegistro = @pMontoRegistro
          AND CO_Registro.InicioEjecucion = @pInicioEjecucion
          AND CO_Registro.FinEjecucion = @pFinEjecucion
          AND CO_Registro.IdFactura = @pIdFactura
          AND CO_Registro.IdGastoRubro = @pIdGastoRubro

    SELECT @totalGasto = ISNULL(SUM(CO_Registro.MontoRegistro), 0)
    FROM CO_Registro (NOLOCK)
    WHERE CO_Registro.IdFactura = @pIdFactura
          AND CO_Registro.IdRegistro <> @pIdRegistro

    SELECT @totalFactura = ISNULL(Fi_Factura.SubTotal, 0)
    FROM Fi_Factura
    WHERE Fi_Factura.IdFactura = @pIdFactura

    IF @numReg > 0
	BEGIN
		SET @error = 'A0001-Se ha agregado el registro pero ya existe un registro con la misma coincidencia de Instalación, Programa, Factura, Rubro, Monto y Fechas de Ejecución';
	END

    IF @totalGasto + ISNULL(@pMontoRegistro, 0) > (@totalFactura + 0.1)
    BEGIN
        SET @error = 'E0001-No es posible registrar el gasto ya que se excedería el total de la factura. Solo se puede capturar hasta $' + CAST((ISNULL(@totalFactura, 0) - ISNULL(@totalGasto, 0)) AS VARCHAR) + ' en el monto';
    END

    IF EXISTS
    (
        SELECT 1
        FROM CO_PolizasDiarioDetalle (NOLOCK)
            INNER JOIN CO_PolizasDiario (NOLOCK)
                ON  CO_PolizasDiarioDetalle.IdPoliza =  CO_PolizasDiario.IdPoliza 
        WHERE CO_PolizasDiarioDetalle.IdGasto = @pIdRegistro
              AND CO_PolizasDiario.Generada = 1
    )
    BEGIN
        SET @error = @error + '|E0002-No es posible modificar el registro ya que hay una póliza generada ligada a este gasto'
    END
    ---------------------------------------------------------------------------------------------------------
    SELECT @idContrato = dbo.FI_Factura.IdContrato
    FROM dbo.FI_Factura (NOLOCK)
    WHERE dbo.FI_Factura.IdFactura = @pIdFactura

    IF (@idContrato IN (   10043,                                    --Jaguar corporativo =1 contrato
                           10018, 10017, 10016, 10015, 10014,        --Jaguar =5 contratos
                           10019, 10020, 10021, 10022, 10023, 10024, --Pantera=6 contratos
                           10052                                     --JEP Servicios Corporativo= 1 contrato
                       )
       )
    BEGIN
        SET @error = ''; --Se añadio para que no devuelva nada en la validación, solo es temporal
    END
    ---------------------------------------------------------------------------------------------------------
    RETURN @error
END