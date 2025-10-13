IF OBJECT_ID(N'dbo.USP_UPD_AP_Usuario', N'P') IS NOT NULL
    DROP PROCEDURE dbo.USP_UPD_AP_Usuario;
GO

CREATE PROCEDURE dbo.USP_UPD_AP_Usuario
    @pUsuarioID      INT,
    @pUsuario        VARCHAR(100),
    @pNombre         VARCHAR(250),
    @pFoto           VARBINARY(MAX) = NULL,  -- opcional, si NULL no se cambia
    @pModificadoPor  INT,
    @pIsActivo       BIT,
    @pRuta           INT,
    @pPass            VARBINARY(MAX) = NULL,  -- opcional (hash)
    @pSalt            VARBINARY(MAX) = NULL   -- opcional (salt)
AS
BEGIN
    SET NOCOUNT ON;

    /*
      Reglas:
      - Si @pFoto IS NULL -> conserva la foto actual.
      - Si @pass/@salt son NULL o 0x -> conserva los valores actuales de Pass/Salt.
      - Contraseña en texto plano ya no se usa (queda siempre vacío).
      - IsEliminado = 0 cuando IsActivo = 1; en otro caso 1.
      - Dominio se deriva del correo (@pUsuario).
    */

    DECLARE @tocaPassSalt BIT =
        CASE 
            WHEN @pPass IS NOT NULL AND @pSalt IS NOT NULL AND @pPass <> 0x AND @pSalt <> 0x THEN 1
            ELSE 0
        END;

    IF (@tocaPassSalt = 1)
    BEGIN
        UPDATE dbo.AP_Usuario
        SET Usuario       = @pUsuario,
            Nombre        = @pNombre,
            ModificadoPor = @pModificadoPor,
            ModificadoEl  = GETDATE(),
            foto          = CASE WHEN @pFoto IS NULL THEN foto ELSE @pFoto END,
            IsActivo      = @pIsActivo,
            IsEliminado   = CASE WHEN ISNULL(@pIsActivo, 0) = 1 THEN 0 ELSE 1 END,
            idRuta        = @pRuta,
            Pass          = @pPass,
            Salt          = @pSalt,
            Contraseña    = '', -- siempre vacío
            Dominio       = SUBSTRING(LTRIM(RTRIM(@pUsuario)),
                                      CHARINDEX('@', LTRIM(RTRIM(@pUsuario))) + 1,
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
            foto          = CASE WHEN @pFoto IS NULL THEN foto ELSE @pFoto END,
            IsActivo      = @pIsActivo,
            IsEliminado   = CASE WHEN ISNULL(@pIsActivo, 0) = 1 THEN 0 ELSE 1 END,
            idRuta        = @pRuta,
            Contraseña    = '', -- siempre vacío
            Dominio       = SUBSTRING(LTRIM(RTRIM(@pUsuario)),
                                      CHARINDEX('@', LTRIM(RTRIM(@pUsuario))) + 1,
                                      LEN(LTRIM(RTRIM(@pUsuario))))
        WHERE UsuarioID = @pUsuarioID;
    END;
END
GO
