---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:			Manuel Cruz
-- Modificado por:	Jose Antonio Roman
-- Create date:		26-01-17
-- Modificado el:	17-08-17
-- Description:		Valida que exista exista un RFC y regresa cuantas empresas y usuarios existen
-- =============================================
CREATE PROCEDURE [dbo].[SP_SegValidacionRFC] --HOE0904178T7

    @RFC NVARCHAR(MAX)
AS
BEGIN
    DECLARE @IsRegistrado INT,
            @Usuarios INT;
    DECLARE @IdProveedorRegistrado INT;

    SET @IsRegistrado =
    (
        SELECT COUNT(RFC) FROM S_Proveedor AS P WHERE RFC = @RFC
    );

    IF (@IsRegistrado > 0)
    BEGIN
        SET @Usuarios =
        (
            SELECT COUNT(up.IdUsuario)
            FROM dbo.S_UsuarioProveedor AS up
                INNER JOIN dbo.S_Proveedor p
                    ON up.IdProveedor = p.IdProveedor
            WHERE p.RFC = @RFC
        );
    END;
    ELSE
    BEGIN
        SET @Usuarios = 0;
    END;
    SELECT @IsRegistrado,
           @Usuarios;
END;


