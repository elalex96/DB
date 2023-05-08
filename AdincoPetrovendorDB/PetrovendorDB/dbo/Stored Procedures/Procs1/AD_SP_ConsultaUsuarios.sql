
CREATE PROCEDURE [dbo].[AD_SP_ConsultaUsuarios]
AS
BEGIN
    DECLARE @cuentaNulos INT,
            @contador INT = 1

    DECLARE @tablaUsuario AS TABLE
    (
        Fila INT,
        IdUsuarioProveedor INT,
        IdUsuario INT,
        Nombre NVARCHAR(MAX),
        Correo NVARCHAR(MAX),
        Activo BIT,
        FechaRegistro DATETIME,
        FechaActivacion DATETIME,
        IdTipoUsuario INT,
        IsEliminado BIT,
        IdUsuarioADINCO INT,
        IdProveedor INT,
        RFC NVARCHAR(MAX),
        RazonSocial NVARCHAR(MAX),
		CorreoVerificado BIT
    )

    --Se insertan los usuarios que por algun motivo no tienen asignado IdProveedor
    INSERT INTO @tablaUsuario
    (
        Fila,
        IdUsuarioProveedor,
        IdUsuario,
        Nombre,
        Correo,
        Activo,
        FechaRegistro,
        FechaActivacion,
        IdTipoUsuario,
        IsEliminado,
        IdUsuarioADINCO,
        IdProveedor,
        RFC,
        RazonSocial,
		CorreoVerificado
    )
    SELECT ROW_NUMBER() OVER (ORDER BY up.IdUsuarioProveedor),
           up.IdUsuarioProveedor,
           u.IdUsuario,
           u.Nombre,
           u.Correo,
           ISNULL(u.Activo, 0) AS Activo,
           u.FechaRegistro,
           u.FechaActivacion,
           u.IdTipoUsuario,
           ISNULL(u.IsEliminado, 0) AS IsEliminado,
           u.IdUsuarioADINCO AS IdUsuarioADINCO,
           p.IdProveedor,
           p.RFC,
           p.RazonSocial,
		   u.CorreoVerificado
    FROM dbo.S_Usuario AS u
        LEFT JOIN dbo.S_UsuarioProveedor AS up
            ON up.IdUsuario = u.IdUsuario
        LEFT JOIN dbo.S_Proveedor AS p
            ON p.IdProveedor = up.IdProveedor
    WHERE ISNULL(IdUsuarioProveedor, -1) = -1
    ORDER BY u.Nombre

    SELECT @cuentaNulos = COUNT(*)
    FROM @tablaUsuario

    WHILE @cuentaNulos >= @contador
    BEGIN
        UPDATE @tablaUsuario
        SET IdUsuarioProveedor = @contador * -1 --para asignar numero negativo y saber que ese campo esta nulo
        WHERE Fila = @contador


        SET @contador += 1
    END

    --Se insertan todos los usuarios que tienen idusuarioproveedor
    INSERT INTO @tablaUsuario
    (
        Fila,
        IdUsuarioProveedor,
        IdUsuario,
        Nombre,
        Correo,
        Activo,
        FechaRegistro,
        FechaActivacion,
        IdTipoUsuario,
        IsEliminado,
        IdUsuarioADINCO,
        IdProveedor,
        RFC,
        RazonSocial,
		CorreoVerificado
    )
    SELECT ROW_NUMBER() OVER (ORDER BY up.IdUsuarioProveedor),
           up.IdUsuarioProveedor,
           u.IdUsuario,
           u.Nombre,
           u.Correo,
           ISNULL(u.Activo, 0) AS Activo,
           u.FechaRegistro,
           u.FechaActivacion,
           u.IdTipoUsuario,
           ISNULL(u.IsEliminado, 0) AS IsEliminado,
           u.IdUsuarioADINCO AS IdUsuarioADINCO,
           p.IdProveedor,
           p.RFC,
           p.RazonSocial,
		   u.CorreoVerificado
    FROM dbo.S_Usuario AS u
        LEFT JOIN dbo.S_UsuarioProveedor AS up
            ON up.IdUsuario = u.IdUsuario
        LEFT JOIN dbo.S_Proveedor AS p
            ON p.IdProveedor = up.IdProveedor
    WHERE IdUsuarioProveedor IS NOT NULL
    ORDER BY u.Nombre

	--Retorno a la vista
    SELECT IdUsuarioProveedor,
           IdUsuario,
           Nombre,
           Correo,
           Activo,
           FechaRegistro,
           FechaActivacion,
           IdTipoUsuario,
           IsEliminado,
           IdUsuarioADINCO,
           IdProveedor,
           RFC,
           RazonSocial,
		   CorreoVerificado
    FROM @tablaUsuario
    ORDER BY IdUsuario

END


