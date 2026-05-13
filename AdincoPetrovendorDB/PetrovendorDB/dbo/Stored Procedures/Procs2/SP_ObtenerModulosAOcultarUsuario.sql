
-- =============================================
-- Author:		<Pedro,Acuña>
-- Modified date: <03/01/2018,>
-- Description:	<script donde se obtienen las paginas a ocultar,>
-- =============================================
-- =============================================
-- Author:		DAC
-- Modified date: <07/03/2023>
-- Description:	AGREGADO DE OPTIMIZACÓN
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
    FROM Modulo M (NOLOCK)
        LEFT JOIN AdministracionPermisosUsuarios PM (NOLOCK)
            ON M.IdModulo = PM.IdModulo
    WHERE PM.Activo = 1
          AND PM.IdProveedor = @IdProveedor
		  AND PM.IdFiltroUsuario = @IdUsuario
          AND M.Aplicacion = @IdAplicacion
END

