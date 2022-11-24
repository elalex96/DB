-- =============================================
-- Author:		<Pedro,Acuña>
-- Modified date: <02/01/2018>
-- Description:	<Se aplia la cantidad de caracteres de la contraseña>

-- Author:		<Abel Rivera>
-- Modified date: <21/04/2018>
-- Description:	se agregaron los parametros correoValidacion y notificacionActualizaciones
-- =============================================
CREATE PROCEDURE [dbo].[SP_InsUsuarioGeneral]
    @Nombre VARCHAR(50),
    @correo NVARCHAR(MAX),
    @contrasena NVARCHAR(MAX),
    @idtipousuario INT,
    @idproveedor INT,
    @IdUsuario INT,
    @IdContrato INT,
    @fchRegistro DATETIME
AS
BEGIN

    DECLARE @registrado AS DATETIME = GETDATE()
    DECLARE @idusuarioCorreo INT
    DECLARE @idu INT


    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --revisar si existe como correo inactivo
    SELECT @idusuarioCorreo = IdUsuario
    FROM dbo.S_Usuario
    WHERE Correo = @correo
          AND Activo = 0

    IF (ISNULL(@idusuarioCorreo, 0) = 0)
    BEGIN
        INSERT INTO dbo.S_Usuario
        (
            Nombre,
            Correo,
            Contrasena,
            Activo,
            IdTipoUsuario,
            FechaRegistro,
            IsEliminado,
			CorreoVerificado,
			NotificacionActualizaciones
        )
        VALUES
        (@Nombre, @correo, @contrasena, 1, @idtipousuario, @registrado, 0,1,1)

        SELECT @idusuarioCorreo = @@IDENTITY

        INSERT INTO dbo.S_UsuarioProveedor
        (
            IdUsuario,
            IdProveedor,
            IdTipoPaquete,
            IsAdmin
        )
        VALUES
        (@idusuarioCorreo, @idproveedor, NULL, 0)
    END
    ELSE
    BEGIN
        UPDATE dbo.S_Usuario
        SET Activo = 1,
            IsEliminado = 0,
			Nombre = @Nombre,
			Contrasena = @contrasena,
			IdTipoUsuario = @idtipousuario
        WHERE IdUsuario = @idusuarioCorreo
    END



END
