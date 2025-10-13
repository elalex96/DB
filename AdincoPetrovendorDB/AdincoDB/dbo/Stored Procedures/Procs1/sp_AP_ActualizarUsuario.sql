DROP PROCEDURE IF EXISTS dbo.sp_AP_ActualizarUsuario;
GO
-- =============================================
-- Autor:				Neri Garcia del Angel
-- Fecha de Edición:	20 de Febrero del 2023
-- Descripción:			Se ajusta para que obtenga el dominio del correo (Campo Usuario)
-- =============================================
CREATE PROC [dbo].[sp_AP_ActualizarUsuario]
    --  
    @pUsuarioID INT,
    @pUsuario VARCHAR(100),
    @pContraseña VARCHAR(30),
    @pNombre VARCHAR(250),
    @pFoto IMAGE = NULL,
    @pModificadoPor INT,
    @pPerfilIds VARCHAR(250),
    @pIsActivo BIT,
    @pRuta INT,
    @pass VARBINARY(MAX) = NULL,
    @salt VARBINARY(MAX) = NULL
--  
AS
BEGIN
    DECLARE @pPerfilUsuarioID INT;

    CREATE TABLE #tmpPerfiles (PerfilId INT);

    BEGIN TRAN;

    IF (@pass = 0x OR @salt = 0x)
    BEGIN
        UPDATE AP_Usuario
        SET Usuario = @pUsuario,
            Contraseña = CASE
                             WHEN ISNULL(@pContraseña, '') <> '' THEN
                                 ISNULL(@pContraseña, '')
                             ELSE
                                 Contraseña
                         END,
            Nombre = @pNombre,
            ModificadoPor = @pModificadoPor,
            ModificadoEl = GETDATE(),
            foto = @pFoto,
            IsActivo = @pIsActivo,
            IsEliminado = CASE
                              WHEN isnull(@pIsActivo, 0) = 1 THEN
                                  0
                              ELSE
                                  1
                          END,
            idRuta = @pRuta,
            Dominio = SUBSTRING(
                                   LTRIM(RTRIM(@pUsuario)),
                                   CHARINDEX('@', LTRIM(RTRIM(@pUsuario))) + 1,
                                   LEN(LTRIM(RTRIM(@pUsuario)))
                               )
        WHERE UsuarioID = @pUsuarioID;
    END;
    ELSE
    BEGIN
        UPDATE AP_Usuario
        SET Usuario = @pUsuario,
            Contraseña = CASE
                             WHEN ISNULL(@pContraseña, '') <> '' THEN
                                 ISNULL(@pContraseña, '')
                             ELSE
                                 Contraseña
                         END,
            Nombre = @pNombre,
            ModificadoPor = @pModificadoPor,
            ModificadoEl = GETDATE(),
            foto = @pFoto,
            IsActivo = @pIsActivo,
            IsEliminado = CASE
                              WHEN isnull(@pIsActivo, 0) = 1 THEN
                                  0
                              ELSE
                                  1
                          END,
            idRuta = @pRuta,
            Pass = @pass,
            Salt = @salt,
            Dominio = SUBSTRING(
                                   LTRIM(RTRIM(@pUsuario)),
                                   CHARINDEX('@', LTRIM(RTRIM(@pUsuario))) + 1,
                                   LEN(LTRIM(RTRIM(@pUsuario)))
                               )
        WHERE UsuarioID = @pUsuarioID;
    END;

    IF @@error <> 0
    BEGIN
        ROLLBACK TRAN;

        GOTO fin;
    END;

    /********************PERFILES*************************/
    INSERT INTO #tmpPerfiles
    (
        PerfilId
    )
    SELECT splitdata
    FROM [dbo].[fnSplitString](@pPerfilIds, ',');

    IF @@error <> 0
    BEGIN
        ROLLBACK TRAN;

        GOTO fin;
    END;

    /**********Eliminar los perfiles que no esten marcados*************/
    DELETE AP_perfilusuario
    FROM AP_perfilusuario pu
    WHERE pu.UsuarioID = @pUsuarioID
          AND NOT EXISTS
    (
        SELECT 1 FROM #tmpPerfiles tmp WHERE tmp.PerfilId = pu.PerfilID
    );

    IF @@error <> 0
    BEGIN
        ROLLBACK TRAN;

        GOTO fin;
    END;

    /*********Insertar los perfiles marcados******************/
    SELECT @pPerfilUsuarioID = isnull(MAX(PerfilUsuarioID), 0)
    FROM ap_perfilusuario (NOLOCK);

    INSERT INTO ap_perfilusuario
    (
        /*PerfilUsuarioID,*/
        UsuarioID,
        PerfilID,
        CreadoPor,
        RandomUpdate
    )
    SELECT
        @pUsuarioID,
        PerfilID,
        @pModificadoPor,
        NULL
    FROM #tmpPerfiles T1
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM ap_perfilusuario  (NOLOCK) S1
        WHERE S1.UsuarioID = @pUsuarioID
              AND S1.PerfilID = T1.PerfilId
    );

    IF @@error <> 0
    BEGIN
        ROLLBACK TRAN;

        GOTO fin;
    END;

    COMMIT TRAN;

    fin:
END;