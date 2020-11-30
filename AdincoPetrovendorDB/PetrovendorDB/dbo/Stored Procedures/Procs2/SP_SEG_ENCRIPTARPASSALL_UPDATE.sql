-- =============================================
-- Author:		<Pedro ,,Acuña >
-- Create date: <02/Enero/2018>
-- Description:	<Ya que se tiene a todos los usuarios se actualizan las contraseñas de todos los usuarios
--				que no tienen encriptadas sus contraseñas>
-- =============================================
CREATE PROCEDURE SP_SEG_ENCRIPTARPASSALL_UPDATE
(
    @IdUsuario INT,
    @Password NVARCHAR(MAX),
    @IdContrato INT,
    @fchRegistro DATETIME
)
AS
BEGIN
    UPDATE dbo.S_Usuario
    SET Contrasena = @Password
    WHERE IdUsuario = @IdUsuario
END