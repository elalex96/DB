-- =============================================  
-- Author:  <Author,,Name>  
-- Create date: <Create Date,,>  
-- Description: <Description,,>  
-- =============================================  
-- Author:  <Marcos Neri>  
-- Alter date:  <18-02-2020>  
-- Description: <Agregar pass y salt en el update>  
-- =============================================  
CREATE PROCEDURE [dbo].[SP_SegRenovarContrasena]  
-- Add the parameters for the stored procedure here  
@idusuario INT,   
@Pass      VARBINARY(MAX),   
@Salt      VARBINARY(MAX)  
--@contrasena NVARCHAR(50)  
AS  
     BEGIN  
         DECLARE @respuesta BIT= 1;  
         -- SET NOCOUNT ON added to prevent extra result sets from  
         -- interfering with SELECT statements.  
         SET NOCOUNT ON;  
         -- Insert statements for procedure here  
         --UPDATE dbo.AP_Usuario  
         --  SET   
         --      Contraseña = @contrasena  
         --WHERE UsuarioID = @idusuario;  
  
         UPDATE dbo.AP_Usuario  
           SET   
               Pass = @Pass,   
               Salt = @Salt  
         WHERE UsuarioID = @idusuario   AND ISNULL(IsGrupo,0)	=	0; 
         --  
         SELECT Usuario  
         FROM AP_Usuario  
         WHERE UsuarioID = @idusuario  
               AND IsActivo = 1
			   AND ISNULL(IsGrupo,0)	=	0;  
     END;