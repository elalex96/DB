
-- =============================================
-- Author:		<Pedro,Acuña>
-- Modified date: <03/01/2018,>
-- Description:	<script donde se obtienen las paginas a ocultar,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ObtenerModulosAOcultarUsuario]
	
	@IdProveedor INT,
    @IdAplicacion INT,
    @IdUsuario INT,
    @IdContrato INT = NULL,
    @fchRegistro DATETIME = NULL
AS
BEGIN

    SET NOCOUNT ON;

    SELECT StringModuloId
    FROM Modulo M
        LEFT JOIN AdministracionPermisosUsuarios PM
            ON M.IdModulo = PM.IdModulo
    WHERE PM.Activo = 1
          AND PM.IdProveedor = @IdProveedor
		  AND PM.IdFiltroUsuario = @IdUsuario
          AND M.Aplicacion = @IdAplicacion
END

