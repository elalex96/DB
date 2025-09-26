IF OBJECT_ID(N'dbo.USP_UPD_AP_Usuario', N'P') IS NOT NULL
    DROP PROCEDURE dbo.USP_UPD_AP_Usuario;
GO

CREATE PROCEDURE dbo.USP_UPD_AP_Usuario
    @pUsuarioID      INT,
    @pUsuario        VARCHAR(100),
    @pNombre         VARCHAR(250),
    @pFoto           VARBINARY(MAX) = NULL,  -- si es NULL, la columna quedará NULL
    @pModificadoPor  INT,
    @pIsActivo       BIT,
    @pRuta           INT,
    @pPass           VARBINARY(MAX) = NULL,  -- opcional
    @pSalt           VARBINARY(MAX) = NULL   -- opcional
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @tocaPassSalt BIT =
        CASE 
            WHEN @pPass IS NOT NULL AND @pSalt IS NOT NULL 
                 AND DATALENGTH(@pPass) > 0 AND DATALENGTH(@pSalt) > 0 THEN 1
            ELSE 0
        END;

    IF (@tocaPassSalt = 1)
    BEGIN
        UPDATE dbo.AP_Usuario
        SET Usuario       = @pUsuario,
            Nombre        = @pNombre,
            ModificadoPor = @pModificadoPor,
            ModificadoEl  = GETDATE(),
            Foto          = @pFoto,  -- se asigna tal cual (NULL borra la foto)
            IsActivo      = @pIsActivo,
            IsEliminado   = CASE WHEN ISNULL(@pIsActivo, 0) = 1 THEN 0 ELSE 1 END,
            idRuta        = @pRuta,
            Pass          = @pPass,
            Salt          = @pSalt,
            Contraseña    = '',
            Dominio       = SUBSTRING(LTRIM(RTRIM(@pUsuario)),
                                      NULLIF(CHARINDEX('@', LTRIM(RTRIM(@pUsuario))),0) + 1,
                                      LEN(LTRIM(RTRIM(@pUsuario))))
        WHERE UsuarioID = @pUsuarioID;
    END
    ELSE
    BEGIN
        UPDATE dbo.AP_Usuario
        SET Usuario       = @pUsuario,
            Nombre        = @pNombre,
            ModificadoPor = @pModificadoPor,
            ModificadoEl  = GETDATE(),
            Foto          = @pFoto,  -- se asigna tal cual (NULL borra la foto)
            IsActivo      = @pIsActivo,
            IsEliminado   = CASE WHEN ISNULL(@pIsActivo, 0) = 1 THEN 0 ELSE 1 END,
            idRuta        = @pRuta,
            Contraseña    = '',
            Dominio       = SUBSTRING(LTRIM(RTRIM(@pUsuario)),
                                      NULLIF(CHARINDEX('@', LTRIM(RTRIM(@pUsuario))),0) + 1,
                                      LEN(LTRIM(RTRIM(@pUsuario))))
        WHERE UsuarioID = @pUsuarioID;
    END
END
GO
