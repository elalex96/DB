CREATE PROCEDURE [dbo].[SP_CO_GastoEstadoSelects] 
	@EstadoRegistroId INT, @Tipo NVARCHAR(MAX), @IdContrato INT
    AS
BEGIN
		IF(@Tipo = 'Catalogo')
		BEGIN
			SELECT IdClvEstado, NombreEstado FROM CO_EstadoRegistro_V2 WHERE IdContrato = @IdContrato AND ACTIVO = 1
		END
		
		IF(@Tipo = 'Factura')
		BEGIN
			SELECT IdFactura FROM CO_Registro WHERE IdRegistro = @EstadoRegistroId
		END

		IF(@Tipo = 'Registro')
		BEGIN
			Declare @IdFactura int
			SELECT @IdFactura = IdFactura FROM CO_Registro WHERE IdRegistro = @EstadoRegistroId
			SELECT IdRegistro FROM CO_Registro WHERE IdFactura = @IdFactura
		END
	 END