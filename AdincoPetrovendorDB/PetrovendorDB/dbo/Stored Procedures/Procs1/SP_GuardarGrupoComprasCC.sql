-- =============================================
-- Author:		Daniel AC
-- Create date: 13/08/2018
-- Description:	Guardar los roles del usuario
-- =============================================

CREATE PROCEDURE [dbo].[SP_GuardarGrupoComprasCC] @IdUsuario     INT, 
                                                 @IdProveedor   INT, 
                                                 @IdCentroCosto INT, 
                                                 @IdUsuarios    NVARCHAR(MAX)
AS
     DECLARE @Usuarios NVARCHAR(MAX)= @IdUsuarios;
    BEGIN
        DECLARE @tablaIdRoles TABLE
        (Id               INT IDENTITY, 
         IdUsuarioCompras INT
        );
        INSERT INTO @tablaIdRoles(IdUsuarioCompras)
               SELECT splitdata
               FROM dbo.fnSplitString(@Usuarios, ' ');
        DECLARE @cantidadRoles INT;
        SELECT @cantidadRoles = COUNT(*)
        FROM @tablaIdRoles;
        IF(@cantidadRoles = 0) --actualizar a que ese centro de costo no tiene usuarios de compras asignados
            BEGIN
                UPDATE dbo.CC_CentroCostoGrupoCompras
                  SET 
                      Activo = 0, 
                      ModificadoEl = GETDATE()
                WHERE IdCentroCosto = @IdCentroCosto
                      AND Activo = 1;
        END;
        DECLARE @IdUsuarioComprasAux INT, @Contador INT= 1;
        IF(@cantidadRoles > 0) --primero revisar si existe si es asi activalo si no entonces insertalo en la tabla
            BEGIN
                WHILE(@cantidadRoles >= @Contador)
                    BEGIN
                        SELECT @IdUsuarioComprasAux = IdUsuarioCompras
                        FROM @tablaIdRoles
                        WHERE Id = @Contador;
                        IF EXISTS
                        (
                            SELECT 1
                            FROM dbo.CC_CentroCostoGrupoCompras
                            WHERE IdCentroCosto = @IdCentroCosto
                                  AND IdUsuario = @IdUsuarioComprasAux
                        )
                            BEGIN
                                UPDATE dbo.CC_CentroCostoGrupoCompras
                                  SET 
                                      Activo = 1, 
                                      ModificadoEl = GETDATE(), 
                                      ModificadoPor = @IdUsuario
                                WHERE IdUsuario = @IdUsuarioComprasAux
                                      AND IdCentroCosto = @IdCentroCosto;
                        END;
                            ELSE
                            BEGIN
                                INSERT INTO dbo.CC_CentroCostoGrupoCompras
                                (IdCentroCosto, 
                                 IdUsuario, 
                                 Activo, 
                                 CreadoEl, 
                                 CreadoPor
                                )
                                VALUES
                                (@IdCentroCosto, -- IdCentroCosto - int
                                 @IdUsuarioComprasAux, -- IdUsuario - int
                                 1, -- Activo - bit
                                 GETDATE(), -- CreadoEl - datetime
                                 @IdUsuario -- CreadoPor - int								   
                                );
                        END;
                        SET @Contador+=1;
        END;
        END;

        --EN CASO DE QUE SE ELIMINEN ROLES
        UPDATE dbo.CC_CentroCostoGrupoCompras
          SET 
              Activo = 0, 
              ModificadoEl = GETDATE(), 
              ModificadoPor = @IdUsuario
        WHERE IdUsuario NOT IN
        (
            SELECT IdUsuarioCompras
            FROM @tablaIdRoles
        )
              AND IdCentroCosto = @IdCentroCosto
              AND Activo = 1;
    END;
