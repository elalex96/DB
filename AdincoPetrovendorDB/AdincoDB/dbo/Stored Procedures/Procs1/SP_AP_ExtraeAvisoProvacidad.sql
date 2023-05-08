-- =============================================  
-- Author: Reyna Olvera
-- Create date:   20200215
-- Description:  
-- =============================================  
CREATE PROCEDURE [dbo].[SP_AP_ExtraeAvisoProvacidad]
AS 
  BEGIN 
      SET NOCOUNT ON; 

	SELECT  AvisoPrivacidad FROM AP_AvisoProvacidad WHERE ACTIVO=1

  END; 