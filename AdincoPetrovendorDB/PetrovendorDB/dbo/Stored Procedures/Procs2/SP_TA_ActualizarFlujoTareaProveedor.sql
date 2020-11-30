-- =============================================
-- Author:		Pedro Acuña
-- Create date: 23/01/2018
-- Description:	actualizar flujo de aprobación de Solicitud de pedido
-- =============================================
-- =============================================
-- Author:		Abel Rivera
-- Create date: 12/09/2019
-- Description:	Valida cuando el flujo de factura activo de desactiva, activando otro flujo para siempre exista un flujo de factura activo
-- =============================================

CREATE PROCEDURE [dbo].[SP_TA_ActualizarFlujoTareaProveedor] @IdProveedor    INT, 
                                                             @IdFlujoTarea   INT, 
                                                             @IdUsuario      INT, 
                                                             @Accion         NVARCHAR(300), 
                                                             @Nombre         NVARCHAR(MAX), 
                                                             @Descripcion    NVARCHAR(MAX), 
                                                             @Predeterminado BIT
AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @TipoOperacion INT;
        IF @Accion = 'UPDATE'
            BEGIN
                IF(@Predeterminado = 1)
                    BEGIN
                        SELECT @TipoOperacion = IdTipoOperacion
                        FROM dbo.TA_FlujoTarea
                        WHERE IdProveedor = @IdProveedor
                              AND IdFlujoTarea = @IdFlujoTarea;
                        UPDATE TA_FlujoTarea
                          SET 
                              Predeterminado = 0
                        WHERE IdTipoOperacion = @TipoOperacion
                              AND IdProveedor = @IdProveedor;
                END;
                UPDATE [dbo].[TA_FlujoTarea]
                  SET 
                      [Nombre] = @Nombre, 
                      [Descripcion] = @Descripcion, 
                      [IdModificadoPor] = @IdUsuario, 
                      [ModificadorEl] = GETDATE(), 
                      Predeterminado = @Predeterminado
                WHERE [IdFlujoTarea] = @IdFlujoTarea
                      AND [IdProveedor] = @IdProveedor;
                DECLARE @Existe_predeterminado INT;
                DECLARE @NewIdFlujoTarea INT;
                IF(@TipoOperacion = 10)
                    BEGIN
                        -- si no hay un flujo activo activar uno
                        SET @Existe_predeterminado =
                        (
                            SELECT COUNT(1)
                            FROM dbo.TA_FlujoTarea
                            WHERE IdProveedor = @IdProveedor
                                  AND Activo = 1
                                  AND IdTipoOperacion = 10
                                  AND ISNULL(Predeterminado, 0) = 1
                        );
                        IF(@Existe_predeterminado = 0)
                            BEGIN
                                SET @NewIdFlujoTarea =
                                (
                                    SELECT TOP 1 IdFlujoTarea
                                    FROM dbo.TA_FlujoTarea
                                    WHERE IdProveedor = @IdProveedor
                                          AND Activo = 1
                                          AND ISNULL(Eliminado, 0) = 0
                                          AND IdTipoOperacion = 10
                                          AND IdFlujoTarea <> @IdFlujoTarea
                                );
                                UPDATE dbo.TA_FlujoTarea
                                  SET 
                                      Predeterminado = 1
                                WHERE IdFlujoTarea = @NewIdFlujoTarea;
                        END;
                END;
                    ELSE
                    BEGIN
                        -- si no hay un flujo activo activar uno
                        SET @Existe_predeterminado =
                        (
                            SELECT COUNT(1)
                            FROM dbo.TA_FlujoTarea
                            WHERE IdProveedor = @IdProveedor
                                  AND Activo = 1
                                  AND IdTipoOperacion = 16
                                  AND ISNULL(Predeterminado, 0) = 1
                        );
                        IF(@Existe_predeterminado = 0)
                            BEGIN
                                SET @NewIdFlujoTarea =
                                (
                                    SELECT TOP 1 IdFlujoTarea
                                    FROM dbo.TA_FlujoTarea
                                    WHERE IdProveedor = @IdProveedor
                                          AND Activo = 1
                                          AND ISNULL(Eliminado, 0) = 0
                                          AND IdTipoOperacion = 16
                                          AND IdFlujoTarea <> @IdFlujoTarea
                                );
                                UPDATE dbo.TA_FlujoTarea
                                  SET 
                                      Predeterminado = 1
                                WHERE IdFlujoTarea = @NewIdFlujoTarea;
                        END;
                END;
        END;
    END;