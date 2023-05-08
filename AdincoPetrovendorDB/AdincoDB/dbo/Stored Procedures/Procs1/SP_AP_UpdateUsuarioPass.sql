-- =============================================  
-- Author:  Marcos Garcia  
-- Create date: 17-02-2020  
-- Description: Update el Salt,Pass por UsuarioID   
--    en el boton de encriptacion de usuarios   
-- =============================================  
CREATE PROC [dbo].[SP_AP_UpdateUsuarioPass]   
--  
@UsuarioID  INT,   
@pass       VARBINARY(MAX) = NULL,   
@salt       VARBINARY(MAX) = NULL,   
@IdContrato INT,   
@IdUsuario  INT  
--  
AS  
     BEGIN  
         UPDATE AP_Usuario  
           SET   
               Pass = @pass,   
               Salt = @salt  
         WHERE UsuarioID = @UsuarioID
		AND ISNULL(IsGrupo,0)=0;  
		  
         IF @@ERROR <> 0  
             SELECT 'False' AS msj;  
             ELSE  
         SELECT 'True' AS msj;  
     END;