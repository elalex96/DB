CREATE PROCEDURE [dbo].[sp_Eliminar_MarcadorMensual]
	@IdContrato INT,
	@IdUsuario INT,
	@IdPrecioMarcadorMensual INT 
AS
BEGIN
    SET NOCOUNT ON;
	DELETE  FROM CO_PrecioMarcadorMensual WHERE IdPrecioMarcadorMensual = @IdPrecioMarcadorMensual;
END;