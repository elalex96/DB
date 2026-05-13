CREATE PROCEDURE [dbo].[sp_ValidacionExistente_MarcadorMensual]
	@IdContrato INT,
	@IdUsuario INT,
	@IdMarcador INT,
	@Mes DATE,
	@Precio FLOAT
AS
BEGIN
    SET NOCOUNT ON;
	IF((SELECT COUNT(1) FROM CO_PrecioMarcadorMensual WHERE IdMarcador = @IdMarcador and IdContrato = @IdContrato  and Mes = @Mes) > 0)
	BEGIN
		SELECT 'Ya existe un registro con el mismo marcador y mes' AS Validacion
	END
END;

