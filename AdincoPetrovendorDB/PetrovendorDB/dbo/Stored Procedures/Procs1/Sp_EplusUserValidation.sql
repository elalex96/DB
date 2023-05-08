-- =============================================
-- Author:      <Author,,Name>
-- Create date: <Create Date,,>
-- Description: <Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Sp_EplusUserValidation]
    @Correo NVARCHAR(400),
    @Usuario NVARCHAR(500),
    @RFC VARCHAR(30),
    @TipoRegimen INT,
    @Nacionalidad INT,
    @RazonSocial NVARCHAR(MAX)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    -- guardamos la informacion que se esta ingresando a la bitacora
    INSERT INTO dbo.S_EplusBitacoraRegistro
    (
        Correo,
        Usuario,
        RFC,
        TipoRegimen,
        Nacionalidad,
        RazonSocial,
        FechaRegistro
    )
    VALUES
    (   @Correo,      -- Correo - nvarchar(400)
        @Usuario,      -- Usuario - nvarchar(500)
        @RFC,       -- RFC - varchar(30)
        @TipoRegimen,        -- TipoRegimen - int
        @Nacionalidad,        -- Nacionalidad - int
        @RazonSocial,      -- RazonSocial - nvarchar(max)
        GETDATE() -- FechaRegistro - datetime
    )
    -------------------------------------------
    ------------------------------------------

    DECLARE @existeUsuario INT;
    DECLARE @ExisteProveedor INT;
    DECLARE @ExisteRelacion INT;
    DECLARE @IdProveedor INT;
    DECLARE @IdUsuario INT;
    SET @existeUsuario =
    (
        SELECT TOP 1 IdUsuario
        FROM S_Usuario
        WHERE Correo = @Correo
              AND ISNULL(Activo, 0) = 1
              AND ISNULL(IsEliminado, 0) = 0
    );
    SET @ExisteProveedor =
    (
        SELECT IdProveedor
        FROM S_Proveedor
        WHERE RFC = @RFC
              AND ISNULL(IsEliminado, 0) = 0
              AND ISNULL(Activo, 0) = 1
    );
    SET @ExisteRelacion =
    (
        SELECT IdUsuarioProveedor
        FROM S_UsuarioProveedor
        WHERE IdUsuario = @existeUsuario
              AND IdProveedor = @ExisteProveedor
    );
    -- verificamos que el usuario exista
    IF @existeUsuario > 0
    BEGIN
        -- verificamos que el proveedore exista
        IF @ExisteProveedor > 0
        BEGIN
                SET @IdUsuario =
                (
                    SELECT TOP 1 IdUsuario
                    FROM S_Usuario
                    WHERE Correo = @Correo
                          AND ISNULL(Activo, 0) = 1
                          AND ISNULL(IsEliminado, 0) = 0
                );
        END
        -- si no existe el proveedor, lo agregamos 
        ELSE
        BEGIN
                INSERT INTO dbo.S_Proveedor
                (
                    IdNacionalidad,
                    RFC,
                    IdTipoRegimen,
                    RazonSocial,
                    IdPais,
                    Activo
                )
                VALUES
                (   @Nacionalidad, -- IdNacionalidad - int
                    @RFC,          -- RFC - varchar(30)
                    @TipoRegimen,  -- IdTipoRegimen - int
                    @RazonSocial,  -- RazonSocial - nvarchar(max)
                    42, 1);
                SET @IdProveedor = @@IDENTITY;
        END
    END -- fin usuario existe
    -- si el usuario no existe
    ELSE
    BEGIN
            INSERT INTO dbo.S_Usuario
            (
                Nombre,
                Correo,
                Contrasena,
                Activo,
                IdTipoUsuario,
                IsEliminado,
                CorreoVerificado,
                FechaRegistro,
                NotificacionActualizaciones
            )
            VALUES
            (   @Usuario,    -- Nombre - nvarchar(100)
                @Correo,     -- Correo - nvarchar(max)
                'ePlusTemp', -- Contrasena - nvarchar(max)
                1, 3, 0, 0, GETDATE(), 1);
            /**2.- llena la variable @IdUsuario con el usuario insertado**/
            SET @IdUsuario =
            (
                SELECT SCOPE_IDENTITY()
            );
            -- si existe el proveedor
            IF @ExisteProveedor > 0
            BEGIN
                    SET @IdProveedor =
                    (
                        SELECT IdProveedor
                        FROM S_Proveedor
                        WHERE RFC = @RFC
                                AND ISNULL(IsEliminado, 0) = 0
                                AND ISNULL(Activo, 0) = 1
                    );
            END
            -- si el proveedor no existe
            ELSE
            BEGIN
                    INSERT INTO dbo.S_Proveedor
                    (
                        IdNacionalidad,
                        RFC,
                        IdTipoRegimen,
                        RazonSocial,
                        IdPais,
                        Activo
                    )
                    VALUES
                    (   @Nacionalidad, -- IdNacionalidad - int
                        @RFC,          -- RFC - varchar(30)
                        @TipoRegimen,  -- IdTipoRegimen - int
                        @RazonSocial,  -- RazonSocial - nvarchar(max)
                        42, 1);
                    SET @IdProveedor = @@IDENTITY;
            END
    END
    IF @existeUsuario > 0 SET @IdUsuario = @existeUsuario
    -- verificamos si la relación existe o no
    IF ISNULL(@ExisteRelacion, 0) = 0
    BEGIN
            INSERT INTO dbo.S_UsuarioProveedor
            (
                IdUsuario,
                IdProveedor,
                IsAdmin
            )
            VALUES
            (   
                @IdUsuario,   -- IdUsuario - int
                @IdProveedor, -- IdProveedor - int
                1             -- IsAdmin - bit
                );
    END
    SELECT @IdUsuario
END