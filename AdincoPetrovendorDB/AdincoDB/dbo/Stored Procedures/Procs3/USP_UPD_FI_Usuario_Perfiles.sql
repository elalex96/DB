IF OBJECT_ID(N'dbo.USP_UPD_FI_Usuario_Perfiles', N'P') IS NOT NULL
    DROP PROCEDURE dbo.USP_UPD_FI_Usuario_Perfiles;
GO

CREATE PROCEDURE dbo.USP_UPD_FI_Usuario_Perfiles
    @pUsuarioID    INT,                -- Usuario al que se le actualizan perfiles
    @pPerfilIds    VARCHAR(250) = NULL,-- CSV: "1,2,3," o "1,2,3"
    @pModificadoPor INT                -- Usuario que realiza el cambio
AS
BEGIN
    SET NOCOUNT ON;

    -- Tabla temporal con los perfiles seleccionados
    CREATE TABLE #tmpPerfiles (PerfilID INT PRIMARY KEY);

    -- Normalizar @pPerfilIds y cargar a tabla temporal
    IF (@pPerfilIds IS NOT NULL AND LTRIM(RTRIM(@pPerfilIds)) <> '')
    BEGIN
        -- Quitar posible coma final para evitar filas vacías
        SET @pPerfilIds = RTRIM(REPLACE(@pPerfilIds + ' ', ', ', ' '));
        IF RIGHT(@pPerfilIds,1) = ',' SET @pPerfilIds = LEFT(@pPerfilIds, LEN(@pPerfilIds)-1);

        INSERT INTO #tmpPerfiles(PerfilID)
        SELECT TRY_CAST(splitdata AS INT)
        FROM dbo.fnSplitString(@pPerfilIds, ',')
        WHERE TRY_CAST(splitdata AS INT) IS NOT NULL;
    END

    BEGIN TRAN;

        /* 1) Eliminar relaciones que ya no están seleccionadas
              - Si #tmpPerfiles está vacío, se eliminan TODAS las relaciones del usuario */
        DELETE pu
        FROM dbo.AP_PerfilUsuario AS pu
        WHERE pu.UsuarioID = @pUsuarioID
          AND NOT EXISTS (
                SELECT 1
                FROM #tmpPerfiles t
                WHERE t.PerfilID = pu.PerfilID
          );

        /* 2) Insertar relaciones nuevas que no existan aún */
        INSERT INTO dbo.AP_PerfilUsuario (UsuarioID, PerfilID, CreadoPor, RandomUpdate)
        SELECT
            @pUsuarioID,
            t.PerfilID,
            @pModificadoPor,
            NULL
        FROM #tmpPerfiles t
        WHERE NOT EXISTS (
            SELECT 1
            FROM dbo.AP_PerfilUsuario x
            WHERE x.UsuarioID = @pUsuarioID
              AND x.PerfilID  = t.PerfilID
        );

    COMMIT TRAN;
END
GO
