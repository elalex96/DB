-- =============================================
-- Author:		<Alexander Gomez>
-- Modified date: <07/09/2018,>
-- Description:	<store para actualizar cuales son las paginas que se van a ocultar por aplicacion,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_AgregarPerfilModuloUsuario]
    @IdModulo INT,
    @Activo BIT,
    @IdProveedor INT,
    --@IntAplicacion INT,
    @IdUsuario INT,
    @IdContrato INT = 0,
    @fchRegistro DATETIME = '20180101',
	@IdRow INT
    --@checkAll INT
AS
DECLARE @IdPerfilModulo INT
DECLARE @CountPerfilModulo INT

BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    SET @CountPerfilModulo =
        (
            SELECT COUNT(IdPerfilModuloUsuario) AS PerfilModuloUsuario
            FROM AdministracionPermisosUsuarios
                INNER JOIN dbo.Modulo M
                    ON M.IdModulo = AdministracionPermisosUsuarios.IdModulo
            WHERE AdministracionPermisosUsuarios.IdModulo = @IdModulo
                  AND AdministracionPermisosUsuarios.IdFiltroUsuario = @IdUsuario
				  AND dbo.AdministracionPermisosUsuarios.IdProveedor = @IdProveedor
                  --AND M.Aplicacion = @IntAplicacion
        )

        IF @CountPerfilModulo > 0
        BEGIN

            SET @IdPerfilModulo =
            (
                SELECT IdPerfilModuloUsuario
                FROM AdministracionPermisosUsuarios
                WHERE IdModulo = @IdModulo
                      AND IdFiltroUsuario = @IdUsuario
					  AND IdProveedor = @IdProveedor
            )

            UPDATE [dbo].[AdministracionPermisosUsuarios]
            SET Activo = @Activo,
				ModificadoEl = GETDATE()
            WHERE IdPerfilModuloUsuario = @IdPerfilModulo

        END
        ELSE
        BEGIN

			INSERT INTO dbo.AdministracionPermisosUsuarios
			(
			    IdModulo,
			    Activo,
			    CreadoEl,
			    IdFiltroUsuario,
			    IdProveedor
			)
			VALUES
			(  
			    @IdModulo,         -- IdModulo - int
			    @Activo,      -- Activo - bit
			    GETDATE(), -- CreadoEl - datetime
			    @IdUsuario,         -- IdFiltroUsuario - int
			    @IdProveedor          -- IdProveedor - int
			   )

            SELECT @@IDENTITY

        END
END