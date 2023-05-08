-- =============================================
-- Author:		Pedro Acuña
-- Create date: 07/03/2018
-- Description:	actualizar los datos de los usuarios que no quieren ser notificados
-- =============================================
CREATE PROCEDURE [dbo].[SP_TA_ModificarNoNotificacion]
    @IdCorreo INT,
    @CheckBox BIT,
    @IdUsuario INT,
    @IdProveedor INT,
    @IdUsuarioModificador INT,
    ------------------------
    @IdContrato INT,
    @FchRegistro DATETIME
-----------------------
AS
BEGIN
    IF EXISTS
    (
        SELECT 1
        FROM dbo.TA_NoNotificacion
        WHERE IdUsuario = @IdUsuario
              AND IdProveedor = @IdProveedor
              AND IdCorreo = @IdCorreo
    )
    BEGIN
        IF (@CheckBox = 1)
        BEGIN
            UPDATE dbo.TA_NoNotificacion
            SET IsEliminado = 1,
                FechaModificacion = GETDATE(),
                IdUsuarioModificado = @IdUsuarioModificador
            WHERE IdProveedor = @IdProveedor
                  AND IdUsuario = @IdUsuario
                  AND IdCorreo = @IdCorreo
        END

        IF (@CheckBox = 0)
        BEGIN
            UPDATE dbo.TA_NoNotificacion
            SET IsEliminado = 0,
                FechaModificacion = GETDATE(),
                IdUsuarioModificado = @IdUsuarioModificador
            WHERE IdProveedor = @IdProveedor
                  AND IdUsuario = @IdUsuario
                  AND IdCorreo = @IdCorreo
        END
    END
    ELSE
    BEGIN
        INSERT INTO dbo.TA_NoNotificacion
        (
            IdUsuario,
            IdProveedor,
            IdCorreo,
            FechaModificacion,
            IdUsuarioModificado,
            FechaCreacion,
            UsuarioCreador,
            IsEliminado
        )
        VALUES
        (   @IdUsuario,            -- IdUsuario - int
            @IdProveedor,          -- IdProveedor - int
            @IdCorreo,             -- IdCorreo - int
            NULL,                  -- FechaModificacion - datetime
            NULL,                  -- IdUsuarioModificado - int
            GETDATE(),             -- FechaCreacion - datetime
            @IdUsuarioModificador, -- UsuarioCreador - int
            0                      -- IsEliminado - bit
        )
    END

END


SELECT * FROM TA_NoNotificacion