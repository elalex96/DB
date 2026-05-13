
-- =============================================
-- Author:		Daniel Cruz
-- Create date: 23-03-17
-- Description:	consulta los correos
			
-- =============================================
CREATE  PROCEDURE [dbo].[SP_AD_ConsultarServidorCorreo] 
	-- Add the parameters for the stored procedure here
	 	 
AS
BEGIN
	 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here

	   SELECT IdServidor,'Servidor: '+CAST(ISNULL(IdServidor,0) AS NVARCHAR(300)) +' '+ISNULL(CuentaRegistro,'SMTP No Disponible') +' - SMPT:' + ISNULL(SMTP,'SMTP No Disponible')+' - Puerto:'+ CAST(ISNULL(Puerto,0) AS NVARCHAR(300)) AS CuentaRegistro
	   FROM dbo.TA_CorreoServidor
	 
	 
END

 