-- =============================================
-- Author:		<Pedro ,,Acuña >
-- Modified date: <02/Enero/2018>
-- Description:	<Se obtiene el usuario y si contraseña para validar la contraseña encriptada >
-- =============================================
CREATE PROCEDURE SP_SeguridadObtenerContra
(
    @Correo NVARCHAR(MAX),
    @IdUsuario INT,
    @IdContrato INT,
    @fchRegistro DATETIME
)
AS
BEGIN
    SELECT IdUsuario,
           Contrasena
    FROM dbo.S_Usuario
    WHERE Correo = @Correo
          AND Activo = 1
          AND IsEliminado = 0
END