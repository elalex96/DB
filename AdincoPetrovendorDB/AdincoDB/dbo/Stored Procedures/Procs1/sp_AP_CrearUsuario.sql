
-- =============================================
-- Author:		
-- Create date: 
-- Description:	Inserta en la tabla AP_Usuario.
-- =============================================
-- 20160627	BAAC	Se modifica para cambiar el tipo de usuario
-- =============================================
-- Autor:				Neri Garcia del Angel
-- Fecha de Edición:	20 de Febrero del 2023
-- Descripción:			Se ajusta para que obtenga el dominio del correo (Campo Usuario)
-- =============================================
CREATE PROCEDURE [dbo].[sp_AP_CrearUsuario]
    --
    @pUsuarioID INT,
    @pUsuario VARCHAR(100),
    @pContraseña VARCHAR(30),
    @pNombre VARCHAR(250),
    @pFoto IMAGE,
    @pCreadoPor INT,
    @pPerfilIds VARCHAR(100),
    @pRuta INT,
    @pass VARBINARY(MAX) = NULL,
    @salt VARBINARY(MAX) = NULL
--
AS
BEGIN
    DECLARE @pPerfilUsuarioID INT;

    CREATE TABLE #tmpPerfiles (PerfilId INT);

    BEGIN TRAN;

    SELECT @pUsuarioID = ISNULL(MAX(UsuarioID), 0) + 1
    FROM AP_Usuario  (NOLOCK);

    INSERT INTO AP_Usuario
    (
        Usuario,
        Contraseña,
        Nombre,
        IsActivo,
        fchRegistro,
        IsEliminado,
        imgsrc,
        UltimoAcceso,
        Idioma,
        CreadoPor,
        IdTipoUsuario,
        Sello,
        IMAGE,
        Foto,
        ModificadoPor,
        ModificadoEl,
        TFAuthentication,
        NumeroCelular,
        CodigoPais,
        IdRuta,
        Pass,
        Salt,
        IsGrupo,
        Dominio
    )
    VALUES
    (
        LTRIM(RTRIM(@pUsuario)),
        @pContraseña,
        @pNombre,
        1,
        GETDATE(),
        0,
        NULL,
        NULL,
        1,
        @pCreadoPor,
        3,
        NULL,
        NULL,
        @pFoto,
        NULL,
        NULL,
        0,
        '8116754103',
        3,
        @pRuta,
        @pass,
        @salt,
        0,
        SUBSTRING(LTRIM(RTRIM(@pUsuario)), CHARINDEX('@', LTRIM(RTRIM(@pUsuario))) + 1, LEN(LTRIM(RTRIM(@pUsuario))))
    );

    /********Obtener el ID generado****************/
    SELECT @pUsuarioID = MAX(UsuarioID)
    FROM AP_Usuario  (NOLOCK)
    WHERE Usuario = LTRIM(RTRIM(@pUsuario));

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
    DELETE AP_PerfilUsuario
    FROM AP_PerfilUsuario pu
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
    SELECT @pPerfilUsuarioID = ISNULL(MAX(PerfilUsuarioID), 0)
    FROM AP_PerfilUsuario  (NOLOCK);

    INSERT INTO AP_PerfilUsuario
    (
        /*PerfilUsuarioID,*/
        UsuarioID,
        PerfilID,
        CreadoPor,
        RandomUpdate
    )
    SELECT
        @pUsuarioID,
        PerfilId,
        @pCreadoPor,
        NULL
    FROM #tmpPerfiles;

    IF @@error <> 0
    BEGIN
        ROLLBACK TRAN;

        GOTO fin;
    END;

    COMMIT TRAN;

    fin:
END;