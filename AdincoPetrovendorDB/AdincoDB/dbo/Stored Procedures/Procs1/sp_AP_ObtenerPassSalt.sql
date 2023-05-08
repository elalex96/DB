-- =============================================  
-- Author:  Marcos Garcia  
-- Create date: 17-02-2020  
-- Description: Obtiene el Salt,Pass,UsuarioID   
--    para validacion de la contraseña  
-- =============================================  
CREATE PROCEDURE [dbo].[sp_AP_ObtenerPassSalt]  
@Usuario    NVARCHAR(MAX) = 0  
AS  
         BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
             SET NOCOUNT ON;  
  
    -- Insert statements for procedure here  
             SELECT   
     U.Pass,  
     U.Salt,  
     U.UsuarioID ,
	 U.IsActivo,
	 U.Nombre
             FROM AP_Usuario U                   
             WHERE(U.usuario = RTRIM(@Usuario))  
                  AND u.IsActivo = 1 AND ISNULL(IsGrupo,0)=0;  
         END;  