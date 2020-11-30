-- =============================================
-- Author:		<Pedro ,,Acuña >
-- Create date: <02/Enero/2018>
-- Description:	<Se Obtienen los admnisitradores por proveedor >
-- =============================================
CREATE PROCEDURE [dbo].SP_DG_ObtenerAdministradores
    @IdProveedor INT,
    @IdUsuario INT,
    @IdContrato INT,
    @fchRegistro DATETIME
AS
BEGIN
    SELECT usuario.IdUsuario,
           usuario.Nombre,
           usuario.Correo
    FROM dbo.S_Usuario usuario
        INNER JOIN dbo.S_UsuarioProveedor uProv
            ON uProv.IdUsuario = usuario.IdUsuario
    WHERE usuario.IdTipoUsuario = 3
          AND usuario.Activo = 1
          AND usuario.IsEliminado = 0
          AND uProv.IdProveedor = @IdProveedor
END