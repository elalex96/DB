CREATE PROCEDURE sp_obtenerIdUsuarioAdinco (@IdUsuarioPetrovendor INT)
AS
BEGIN
    SELECT IdUsuarioADINCO
    FROM dbo.S_Usuario
    WHERE IdUsuario = @IdUsuarioPetrovendor
END