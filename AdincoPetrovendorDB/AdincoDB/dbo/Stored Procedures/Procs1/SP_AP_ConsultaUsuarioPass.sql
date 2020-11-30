-- =============================================
-- Author:		Marcos Garcia
-- Create date: 17-02-2020
-- Description:	Verifica que el Usuario 
--              No cuente con pass para le 
--              encriptación de los usuarios 
-- =============================================
CREATE PROC [dbo].[SP_AP_ConsultaUsuarioPass] 
--
@UsuarioID  INT, 
@IdContrato INT, 
@IdUsuario  INT
--
AS
     BEGIN
         SELECT UsuarioID, 
                Contraseña,
                CASE
                    WHEN Pass IS NULL
                    THEN 0
                    ELSE 1
                END AS PASSSALT
         FROM dbo.AP_Usuario
         WHERE UsuarioID = @UsuarioID;
     END;