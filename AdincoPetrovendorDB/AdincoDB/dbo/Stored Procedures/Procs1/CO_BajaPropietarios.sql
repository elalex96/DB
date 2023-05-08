CREATE PROCEDURE CO_BajaPropietarios
    @IdPropietario INT,
    @idContrato INT = 0,
    @IdUsuario INT = 0
AS
BEGIN

    SET NOCOUNT ON;

    UPDATE CO_PropietariosAreaContractual
    SET Bit_Activo = 0
    WHERE IdPropietario = @IdPropietario;
END;