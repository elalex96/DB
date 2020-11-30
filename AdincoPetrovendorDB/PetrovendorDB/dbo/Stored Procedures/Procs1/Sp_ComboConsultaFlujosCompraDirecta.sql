CREATE PROCEDURE [dbo].[Sp_ComboConsultaFlujosCompraDirecta] (@idProveedor INT)
AS
BEGIN
    SELECT IdFlujoTarea,
           Nombre
    FROM dbo.TA_FlujoTarea
    WHERE IdTipoOperacion = 14
          AND IdProveedor = @idProveedor
	AND Activo=1    
END

