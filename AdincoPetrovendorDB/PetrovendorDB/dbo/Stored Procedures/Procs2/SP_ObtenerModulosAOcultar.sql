CREATE PROCEDURE [dbo].[SP_ObtenerModulosAOcultar]
    @IdPerfil INT,
    @IdProveedor INT,
    @IdAplicacion INT,
    @IdUsuario INT,
    @IdContrato INT,
    @fchRegistro DATETIME
AS
BEGIN

    SET NOCOUNT ON;

    SELECT StringModuloId
    FROM PerfilModulo PM 
        LEFT JOIN Modulo M
            ON M.IdModulo = PM.IdModulo and PM.IdPerfil = @IdPerfil
     where
           PM.Activo = 1
          AND PM.IdFiltroProveedor = @IdProveedor
          AND M.Aplicacion = @IdAplicacion
END
