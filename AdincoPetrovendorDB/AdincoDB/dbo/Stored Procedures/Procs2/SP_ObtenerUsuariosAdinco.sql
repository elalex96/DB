-- =============================================  
-- Author:  Pedro Acuña  
-- Create date: 11-Mar-21  
-- Description: Obtener los usuarios de adinco
-- =============================================  
CREATE PROCEDURE [dbo].[SP_ObtenerUsuariosAdinco]  
AS  
         BEGIN  
             SET NOCOUNT ON;  
             SELECT    
			 U.UsuarioID ,
			 U.Usuario,
			 U.Contraseña,
			 U.Nombre
             FROM AP_Usuario U                   
             WHERE u.IsActivo = 1

         END;  