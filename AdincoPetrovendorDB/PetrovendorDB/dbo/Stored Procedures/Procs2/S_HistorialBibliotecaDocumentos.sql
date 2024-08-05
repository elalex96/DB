USE Petrovendor;
GO
DROP PROC IF EXISTS S_HistorialBibliotecaDocumentos
GO
CREATE PROCEDURE S_HistorialBibliotecaDocumentos
    @IdProveedor INT,
    @IdUsuario INT
AS
BEGIN
    DECLARE @RFC NVARCHAR(13);
    DECLARE @IdTipoUsuario INT;

    -- Obtener el RFC y el IdTipoUsuario
    SELECT @RFC = p.RFC, @IdTipoUsuario = u.IdTipoUsuario
    FROM s_usuarioproveedor up
    JOIN s_proveedor p ON up.IdProveedor = p.IdProveedor
    JOIN s_usuario u ON up.IdUsuario = u.IdUsuario
    WHERE p.IdProveedor = @IdProveedor
      AND u.IdUsuario = @IdUsuario;

    -- Verificar si el RFC está en la lista de restricción y el tipo de usuario
    IF @RFC IN ('PCM171127RVA', 'PMS090112TB0', 'PAL120710ID0')
    BEGIN
	-- Solo se muestra la sección si es administrador o compras 
        IF @IdTipoUsuario = 5 OR @IdTipoUsuario = 3
        BEGIN
            SELECT 'MOSTRAR_SECCION'
			RETURN;
        END
        ELSE
        BEGIN
            SELECT 'OCULTAR_SECCION'
            RETURN;
        END
    END
    ELSE
    BEGIN
        -- Si el RFC no está en la lista, se  muestra la sección
        SELECT 'MOSTRAR_SECCION'
			RETURN;
    END
END;
GO