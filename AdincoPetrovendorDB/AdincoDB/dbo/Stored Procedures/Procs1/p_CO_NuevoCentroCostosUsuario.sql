CREATE PROCEDURE p_CO_NuevoCentroCostosUsuario @pIdUsuario     INT, 
                                              @pIdCentroCosto INT
AS
    BEGIN
        IF EXISTS
        (
            SELECT IdUsuario, 
                   IdCentroCosto
            FROM AP_UsuarioCentroCosto
            WHERE IdUsuario = @pIdUsuario
                  AND IdCentroCosto = @pIdCentroCosto
        )
            BEGIN
                SELECT 0 AS mensaje;
        END;
            ELSE
            BEGIN
                INSERT INTO AP_UsuarioCentroCosto
                (IdUsuario, 
                 IdCentroCosto, 
                 CreadoEl
                )
                VALUES
                (@pIdUsuario, 
                 @pIdCentroCosto, 
                 GETDATE()
                );
        END;
    END;