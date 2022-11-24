CREATE PROCEDURE [dbo].[sp_Insert_Update_PrecioMarcadorMensual]--10007,10,10000,'20220401',12.3333,0
	@IdContrato INT,
	@IdUsuario INT,
	@IdMarcador INT,
	@Mes DATE,
	@Precio FLOAT,
	@IdPrecioMarcadorMensual INT = 0
AS
BEGIN
    SET NOCOUNT ON;
	IF(@IdPrecioMarcadorMensual > 0)
	BEGIN
		UPDATE CO_PrecioMarcadorMensual
		SET Precio =@Precio,
		ModificadoEl = GETDATE(),
		ModificadoPor = @IdUsuario
		WHERE IdPrecioMarcadorMensual = @IdPrecioMarcadorMensual 
	END
	ELSE
	BEGIN
			INSERT INTO	CO_PrecioMarcadorMensual (IdMarcador,IdContrato,Mes,Precio,CreadoPor,CreadoEn)
			VALUES (@IdMarcador,@IdContrato,@Mes,@Precio,@IdUsuario,GETDATE());
	END
END;

