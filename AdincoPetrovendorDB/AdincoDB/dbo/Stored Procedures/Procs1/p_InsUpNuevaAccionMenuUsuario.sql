CREATE PROCEDURE p_InsUpNuevaAccionMenuUsuario @IdUsuario  INT, 
                                              @IdPantalla INT, 
                                              @IdAccion   INT, 
                                              @Permitir   INT
AS
    BEGIN
        IF EXISTS
        (
            SELECT 1
            FROM AP_UsuarioMenuAccion
            WHERE IdUsuario = @IdUsuario
                  AND IdAccion = @IdAccion
                  AND MenuDId = @IdPantalla
        )
            BEGIN
                UPDATE AP_UsuarioMenuAccion
                  SET 
                      Permitir = 1
                WHERE IdUsuario = @IdUsuario
                      AND IdAccion = @IdAccion
                      AND MenuDId = @IdPantalla;
        END;
            ELSE
            BEGIN
                INSERT INTO AP_UsuarioMenuAccion
                (IdUsuario, 
                 MenuDId, 
                 IdAccion, 
                 Permitir, 
                 CreadoEl
                )
                VALUES
                (@IdUsuario, 
                 @IdPantalla, 
                 @IdAccion, 
                 @Permitir, 
                 GETDATE()
                );
                SELECT 'Insertado';
        END;
    END;