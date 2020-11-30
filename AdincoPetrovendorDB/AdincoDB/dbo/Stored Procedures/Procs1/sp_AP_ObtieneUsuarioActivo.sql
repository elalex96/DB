-- =============================================  
-- Author:  Oscar Mtz  
-- Create date: 03/07/2017  
-- Description: Obtiene la cadena sello del usuario.  
-- =============================================  
CREATE PROCEDURE dbo.sp_AP_ObtieneUsuarioActivo  
@Usuario as varchar(200)  
AS  
BEGIN   
 SELECT   
     [Usuario]  
    ,[Contraseña] Contrasenia  
    ,[Nombre]  
    ,[IsActivo]  
    ,[fchRegistro]  
    ,[IsEliminado]  
    ,[imgsrc]  
    ,[image]  
    ,[UltimoAcceso]  
    ,[Idioma]  
    ,[CreadoPor]  
    ,[Sello]  
    ,[UsuarioID]  
 FROM AP_Usuario   
 WHERE Usuario = @Usuario and IsEliminado=0 AND ISNULL(IsGrupo,0)=0;
END