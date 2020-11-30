-- =============================================
-- Author:		<Pedro, Acuña>
-- Modified date: <04/01/2018,>
-- Description:	<store para actualizar cuales son las paginas que se van a ocultar por aplicacion,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_AgregarPerfilModulo]
    @IdPerfil INT,
    @IdModulo INT,
    @Activo BIT,
    @IdProveedor INT,
    @IntAplicacion INT,
    @IdUsuario INT = 0,
    @IdContrato INT = 0,
    @fchRegistro DATETIME = '20180101',
    @checkAll INT
AS
DECLARE @IdPerfilModulo INT
DECLARE @CountPerfilModulo INT

BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    IF (@checkAll = 1)
    BEGIN
        --En caso de haber chekeado todas las empresas entonces hay que hacer un select a todos los proveedores 
        --y recorrerlos a todos para insertar o actualizar el registro de cada una de las empresas
        DECLARE @tablaProveedores TABLE
        (
            Fila INT,
            idProveedor INT
        )
        DECLARE @contador INT = 1,
                @totalFilas INT

        INSERT INTO @tablaProveedores
        (
            Fila,
            idProveedor
        )
        SELECT ROW_NUMBER() OVER (ORDER BY IdProveedor),
               IdProveedor
        FROM dbo.S_Proveedor

        SELECT @totalFilas = COUNT(Fila)
        FROM @tablaProveedores

        WHILE (@totalFilas >= @contador)
        BEGIN
            SELECT @IdProveedor = idProveedor
            FROM @tablaProveedores
            WHERE Fila = @contador

            SET @CountPerfilModulo =
            (
                SELECT COUNT(IdPerfilModulo) AS PerfilModulo
                FROM PerfilModulo
                    INNER JOIN dbo.Modulo M
                        ON M.IdModulo = PerfilModulo.IdModulo
                WHERE IdPerfil = @IdPerfil
                      AND PerfilModulo.IdModulo = @IdModulo
                      AND PerfilModulo.IdFiltroProveedor = @IdProveedor
                      AND M.Aplicacion = @IntAplicacion
            )

            IF @CountPerfilModulo > 0
            BEGIN

                SET @IdPerfilModulo =
                (
                    SELECT IdPerfilModulo
                    FROM PerfilModulo
                    WHERE IdPerfil = @IdPerfil
                          AND IdModulo = @IdModulo
                          AND IdFiltroProveedor = @IdProveedor
                )

                UPDATE [dbo].[PerfilModulo]
                SET Activo = @Activo
                WHERE IdPerfilModulo = @IdPerfilModulo

            END
            ELSE
            BEGIN

                INSERT INTO PerfilModulo
                (
                    [IdPerfil],
                    [IdModulo],
                    IdFiltroProveedor,
                    [Activo]
                )
                VALUES
                (@IdPerfil, @IdModulo, @IdProveedor, @Activo)

                SELECT @@IDENTITY

            END

            SET @contador += 1
        END
    END
    ELSE
    BEGIN
        --Sino fue chekeado todas las empresas entonces solo la empresa seleccionada sera actualizado o insertado el registro
        SET @CountPerfilModulo =
        (
            SELECT COUNT(IdPerfilModulo) AS PerfilModulo
            FROM PerfilModulo
                INNER JOIN dbo.Modulo M
                    ON M.IdModulo = PerfilModulo.IdModulo
            WHERE IdPerfil = @IdPerfil
                  AND PerfilModulo.IdModulo = @IdModulo
                  AND PerfilModulo.IdFiltroProveedor = @IdProveedor
                  AND M.Aplicacion = @IntAplicacion
        )

        IF @CountPerfilModulo > 0
        BEGIN

            SET @IdPerfilModulo =
            (
                SELECT IdPerfilModulo
                FROM PerfilModulo
                WHERE IdPerfil = @IdPerfil
                      AND IdModulo = @IdModulo
                      AND IdFiltroProveedor = @IdProveedor
            )

            UPDATE [dbo].[PerfilModulo]
            SET Activo = @Activo
            WHERE IdPerfilModulo = @IdPerfilModulo

        END
        ELSE
        BEGIN

            INSERT INTO PerfilModulo
            (
                [IdPerfil],
                [IdModulo],
                IdFiltroProveedor,
                [Activo]
            )
            VALUES
            (@IdPerfil, @IdModulo, @IdProveedor, @Activo)

            SELECT @@IDENTITY

        END
    END

END

