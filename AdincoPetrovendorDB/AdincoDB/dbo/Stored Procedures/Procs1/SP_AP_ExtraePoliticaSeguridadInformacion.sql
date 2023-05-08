CREATE PROCEDURE [dbo].[SP_AP_ExtraePoliticaSeguridadInformacion]
AS 
  BEGIN 
      SET NOCOUNT ON; 
	  SELECT  PoliticaSeguridad FROM AP_PoliticaSeguridadInformacion WHERE ACTIVO=1

  END; 

