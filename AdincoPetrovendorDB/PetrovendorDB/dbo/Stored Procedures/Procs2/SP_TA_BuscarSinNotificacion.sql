-- =============================================
-- Author:		Pedro Acuña
-- Create date: 08/03/2018
-- Description:	Retorna un bit para saber si existe o no el usuario que no quiere ser notificado
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 13/04/2018
-- Description:	se modifico para que descarte los usuarios eliminados
-- =============================================
-- Author:		Jose Roman
-- Create date: 23-01-2019
-- Description:	Se excluyen las notificaciones del tipo de correo 23 (Notificacion alta de material) para todas las empresas que no sean 863 (Cardenaz Mora)
-- =============================================
CREATE PROCEDURE SP_TA_BuscarSinNotificacion
    @Destinatario NVARCHAR(MAX),
    @IdProveedor INT,
    @IdUsuario INT,
    @TipoCorreo INT,
    @IdUsuarioCliente INT = 0,
    @Contador INT = 1,
    @CuentaProvedor INT = 0,
    @cuentaRegIguales INT = 0,
    @Correo NVARCHAR(MAX) = '',
    ------------------------
    @IdContrato INT,
    @FchRegistro DATETIME
-----------------
AS
BEGIN
    DECLARE @tablaProveedor TABLE
    (
        fila INT,
        idUsuario INT,
        idProveedor INT,
        Destinatario NVARCHAR(MAX),
        Correo NVARCHAR(MAX),
        iguales BIT
    );

    IF (@TipoCorreo = 23 AND @IdProveedor <> 863)
    BEGIN
        SELECT 0;
    END;
    ELSE
    BEGIN
        --en caso de que el proveedor este en 0 lo busco y si es mas de un proveedor hay que restringirlo en todas las empresas
        IF (@IdProveedor = 0)
        BEGIN
            --SELECT uProv.IdProveedor , usuario.IdUsuario FROM dbo.S_Usuario usuario INNER JOIN dbo.S_UsuarioProveedor uProv ON uProv.IdUsuario = usuario.IdUsuario WHERE usuario.IdUsuario = @IdUsuario AND usuario.Activo =  1 AND usuario.IsEliminado = 0 

            INSERT INTO @tablaProveedor
            (
                fila,
                idUsuario,
                idProveedor
            )
            SELECT ROW_NUMBER() OVER (ORDER BY uProv.IdProveedor DESC),
                   usuario.IdUsuario,
                   uProv.IdProveedor
            FROM dbo.S_Usuario usuario
                INNER JOIN dbo.S_UsuarioProveedor uProv
                    ON uProv.IdUsuario = usuario.IdUsuario
            WHERE usuario.IdUsuario = @IdUsuario
                  AND usuario.Activo = 1
                  AND usuario.IsEliminado = 0
            ORDER BY uProv.IdProveedor DESC;

            SELECT @CuentaProvedor = COUNT(*)
            FROM @tablaProveedor;

            --en caso de que tenga mas de un proveedor
            WHILE (@CuentaProvedor >= @Contador)
            BEGIN
                DECLARE @usuario INT;
                SELECT @IdProveedor = idProveedor,
                       @IdUsuarioCliente = idUsuario
                FROM @tablaProveedor
                WHERE fila = @Contador;
                SELECT @usuario = IdUsuario
                FROM dbo.TA_NoNotificacion
                WHERE IdProveedor = @IdProveedor
                      AND IdUsuario = @IdUsuarioCliente
                      AND IdCorreo = @TipoCorreo
                      AND IsEliminado = 0;

                SELECT @Correo = Correo
                FROM dbo.S_Usuario
                WHERE IdUsuario = @usuario;

                UPDATE tp
                SET tp.Destinatario = @Destinatario,
                    tp.Correo = @Correo,
                    tp.iguales = CASE
                                     WHEN @Destinatario = @Correo THEN
                                         1
                                     ELSE
                                         0
                                 END
                FROM @tablaProveedor tp
                WHERE tp.fila = @Contador;

                --SELECT @usuario ucliente, @Correo correo, @IdProveedor proveedor,  @Contador contador
                SET @Contador += 1;
            END;
            --Revisar si alguno es igual entonces negar el acceso
            SELECT @cuentaRegIguales = COUNT(*)
            FROM @tablaProveedor
            WHERE iguales = 1;
            IF (@cuentaRegIguales > 0)
            BEGIN
                SELECT 0;
            END;
            ELSE
            BEGIN
                SELECT 1;
            END;
        END;
        ELSE
        BEGIN
            SELECT @IdUsuarioCliente = IdUsuario
            FROM dbo.TA_NoNotificacion
            WHERE IdProveedor = @IdProveedor
                  AND IdUsuario = @IdUsuario
                  AND IdCorreo = @TipoCorreo
                  AND IsEliminado = 0;
            SELECT @Correo = Correo
            FROM dbo.S_Usuario
            WHERE IdUsuario = @IdUsuarioCliente
                  AND IsEliminado = 0;

            IF (@Correo = @Destinatario OR (@Correo IS NULL AND @Destinatario IS NULL))
                SELECT 0; --niega el acceso
            ELSE
                SELECT 1; --son diferentes deja que envie la notificacion
        END;
    END;
END;
