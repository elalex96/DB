-- =============================================  
-- Author:  <Author,,Name>  
-- Create date: <Create Date,,>  
-- Description: <Description,,>  
-- =============================================  
CREATE PROCEDURE [dbo].[SP_SegRecuperarContrasena]  
 -- Add the parameters for the stored procedure here  
 @Correo nvarchar(50)  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
    -- Insert statements for procedure here  
 SELECT UsuarioID,Nombre FROM AP_Usuario WHERE Usuario= @Correo AND IsActivo = 1  AND ISNULL(IsGrupo,0)=0;
  
END  
 -- ================================================  
  