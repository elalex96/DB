CREATE PROCEDURE [dbo].[sp_ObtenerIdRegistro]
(
    @IdFactura INT,
    @IdUsuario INT
)
AS
BEGIN
    SELECT IdRegistro
    FROM dbo.CO_Registro
    WHERE IdFactura = @IdFactura
          AND CreadoPor = @IdUsuario
END

