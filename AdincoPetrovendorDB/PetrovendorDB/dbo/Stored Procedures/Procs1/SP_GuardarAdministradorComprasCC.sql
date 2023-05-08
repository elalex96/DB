-- =============================================  
-- Author:  Daniel AC  
-- Create date: 13/08/2018  
-- Description: Guardar los administradores de compras   
-- =============================================  

CREATE PROCEDURE [dbo].[SP_GuardarAdministradorComprasCC] @IdUsuario   INT, 
                                                         @IdProveedor INT, 
                                                         @IdUsuarios  NVARCHAR(MAX)
AS
    BEGIN
        DECLARE @Usuarios NVARCHAR(MAX)= @IdUsuarios;
        DECLARE @tablaIdRoles TABLE
        (Id        INT IDENTITY, 
         IdUsuario INT
        );
        INSERT INTO @tablaIdRoles(IdUsuario)
               SELECT splitdata
               FROM dbo.fnSplitString(@Usuarios, ' ');
        DECLARE @cantidadRoles INT;
        SELECT @cantidadRoles = COUNT(*)
        FROM @tablaIdRoles;
        IF(@cantidadRoles = 0) --actualizar a que ese PROVEEDOR no tiene administradores registrados  
            BEGIN
                UPDATE dbo.CC_AdministradorCompras
                  SET 
                      Activo = 0, 
                      ModificadoEl = GETDATE()
                WHERE IdProveedor = @IdProveedor
                      AND Activo = 1;
        END;
        DECLARE @IdUsuarioComprasAux INT, @Contador INT= 1;
        IF(@cantidadRoles > 0) --primero revisar si existe si es asi activalo si no entonces insertalo en la tabla  
            BEGIN
                WHILE(@cantidadRoles >= @Contador)
                    BEGIN
                        SELECT @IdUsuarioComprasAux = IdUsuario
                        FROM @tablaIdRoles
                        WHERE Id = @Contador;
                        IF EXISTS
                        (
                            SELECT 1
                            FROM dbo.CC_AdministradorCompras
                            WHERE IdProveedor = @IdProveedor
                                  AND IdUsuario = @IdUsuarioComprasAux
                        )
                            BEGIN
                                UPDATE dbo.CC_AdministradorCompras
                                  SET 
                                      Activo = 1, 
                                      ModificadoEl = GETDATE(), 
                                      ModificadoPor = @IdUsuario
                                WHERE IdUsuario = @IdUsuarioComprasAux
                                      AND IdProveedor = @IdProveedor;
                        END;
                            ELSE
                            BEGIN
                                INSERT INTO dbo.CC_AdministradorCompras
                                (IdUsuario, 
                                 Activo, 
                                 CreadoEl, 
                                 CreadoPor, 
                                 IdProveedor
                                )
                                VALUES
                                (@IdUsuarioComprasAux, -- IdUsuario - int  
                                 1, -- Activo - bit  
                                 GETDATE(), -- CreadoEl - datetime  
                                 @IdUsuario, -- CreadoPor - int              
                                 @IdProveedor         -- IdProveedor - int  
                                );
                        END;
                        SET @Contador+=1;
        END;
        END;

        --EN CASO DE QUE SE ELIMINEN ROLES  
        UPDATE dbo.CC_AdministradorCompras
          SET 
              Activo = 0, 
              ModificadoEl = GETDATE(), 
              ModificadoPor = @IdUsuario
        WHERE IdUsuario NOT IN
        (
            SELECT IdUsuario
            FROM @tablaIdRoles
        )
              AND IdProveedor = @IdProveedor
              AND Activo = 1;
        SELECT 'SUCCESS';
    END;