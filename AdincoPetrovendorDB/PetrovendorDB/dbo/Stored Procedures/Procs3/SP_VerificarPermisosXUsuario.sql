
-- =============================================
-- Author:		<Alexander Gomez>
-- Modified date: <07/03/2018>
-- Description:	<Filtro>
-- =============================================
CREATE PROCEDURE [dbo].[SP_VerificarPermisosXUsuario]
    @IdModulo INT,
    @IdUsuario INT,
	@IdProveedor INT,
    @IdContrato INT,
    @fchRegistro DATETIME
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @TIENE_PERMISO INT = (
									SELECT COUNT(PM.IdPerfilModuloUsuario) 
									FROM dbo.AdministracionPermisosUsuarios AS PM
									WHERE PM.IdFiltroUsuario = @IdUsuario
										AND PM.IdProveedor = @IdProveedor
										AND PM.IdModulo = @IdModulo
										AND PM.Activo = 1
                                 )

    IF (@TIENE_PERMISO > 0)
    BEGIN
        SELECT 'PERMISO_DENEGADO'
    END
    ELSE
    BEGIN
        SELECT 'MODULO_ACCESIBLE'
    END



END

