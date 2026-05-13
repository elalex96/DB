-- =============================================
-- Author:		Pedro Acuña
-- Create date: 18/10/2019
-- Description:	revisa que el usuario tenga el rol de aprobador de CN, 
--				esto para saber si se muestra o no el btn de Carta de contenido nacional en la aceptacion de pedido detalle
-- =============================================
CREATE PROCEDURE [dbo].[Sp_RevisarRolUsuarioEsAprobadorCN] @IdUsuario INT
AS
BEGIN

    IF EXISTS
    (
        SELECT 1
        FROM dbo.S_UsuarioRol AS UR
            INNER JOIN dbo.S_Rol AS R
                ON R.IdRol = UR.IdRol
            INNER JOIN dbo.S_Usuario u
                ON u.IdUsuario = UR.IdUsuario
        WHERE u.IdUsuario = @IdUsuario
              AND R.IdRol = 3
              AND UR.Activo = 1
    )
    BEGIN
        SELECT 1 -- El usuario tiene rol de aprobador de Carta de Contenido, se debe mostrar el btn
    END
    ELSE
    BEGIN
        SELECT 0 -- 
    END


END

