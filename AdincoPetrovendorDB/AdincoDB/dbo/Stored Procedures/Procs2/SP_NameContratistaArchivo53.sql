-- =============================================
-- Author:		Reyna O.
-- Create date: 2019-01-19
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SP_NameContratistaArchivo53 --10010,10090
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN

    SET NOCOUNT ON;
    SELECT CASE Rol
                WHEN 'Contratista SCOC' THEN 1
				WHEN 'Administrador SCOC' THEN 2 --Para pantalla de historial, visualiza el boton de reiniciar flujo
                ELSE 1 END
      FROM dbo.AP_PerfilUsuario
      JOIN dbo.AP_Perfil
        ON AP_Perfil.IdPerfil = AP_PerfilUsuario.PerfilID
      JOIN dbo.AP_Rol
        ON AP_Rol.IdRol       = AP_Perfil.IdRol
     WHERE UsuarioID  = @IdUsuario
       AND IdContrato = @IdContrato;
END;

