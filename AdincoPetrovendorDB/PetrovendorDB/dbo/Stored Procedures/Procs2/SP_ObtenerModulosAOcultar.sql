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
    FROM PerfilModulo PM (NOLOCK)
        LEFT JOIN Modulo M (NOLOCK)
            ON PM.IdModulo = M.IdModulo 
			AND PM.IdPerfil = @IdPerfil
     WHERE
           PM.Activo = 1
          AND PM.IdFiltroProveedor = @IdProveedor
          AND M.Aplicacion = @IdAplicacion
END
