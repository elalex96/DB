use Petrovendor 
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_TA_ConsultarCorreoPorAsunto'
)
    DROP PROCEDURE SP_TA_ConsultarCorreoPorAsunto;
GO
-- =============================================  
-- Author:  Daniel Cruz  
-- Create date: 23-03-17  
-- Description: Regresa los tipos de aprobación de una tarea       
-- =============================================  
 CREATE  PROCEDURE [dbo].[SP_TA_ConsultarCorreoPorAsunto]   
 -- Add the parameters for the stored procedure here  
  @Asunto NVARCHAR(MAX)   
   
AS  
BEGIN  
    
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
    -- Insert statements for procedure here  
  SELECT C.HTML, C.Asunto, S.CuentaRegistro, S.Contrasena, S.SMTP, S.Puerto,S.BBC , C.IdCorreo
  FROM TA_Correo AS C  
  INNER JOIN TA_CorreoServidor AS S ON S.IdServidor=C.IdServidor  
  WHERE  C.Asunto  = @Asunto
  
END  
  
  
  