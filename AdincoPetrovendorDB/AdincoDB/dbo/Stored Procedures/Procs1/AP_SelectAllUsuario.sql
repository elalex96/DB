-- ================================================  
CREATE PROCEDURE [dbo].[AP_SelectAllUsuario]   
 -- Add the parameters for the stored procedure here  
 @IdContrato int,  
 @IdUsuario int  
AS  
BEGIN  
 -- =============================================  
 -- Author:  Valeria Rodríguez  
 -- Create date: 18/02/2019  
 -- Description: Extrae a todos los usuarios  
 -- =============================================  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
    -- Insert statements for procedure here  
 SELECT UsuarioID,Nombre AS nombreUsuario FROM AP_Usuario where IsActivo = 1  AND ISNULL(IsGrupo,0)=0
 ORDER BY UsuarioID  
END  