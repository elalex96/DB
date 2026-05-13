-- =============================================
-- Author:		Reyna Olvera
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_TA_ConsultarCorreo] 
	-- Add the parameters for the stored procedure here
	 @IdCorreo int 
	
AS
BEGIN
	 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 --SELECT HTML,Asunto,CuentaRegistro, Contrasena, SMTP, Puerto,BBC
	 --FROM TA_Correo AS C
	 --INNER JOIN TA_CorreoServidor AS S ON S.IdServidor=C.IdServidor
	 --WHERE IdCorreo = @IdCorreo 
	 
 SELECT HTML,Asunto,CuentaRegistro, Contrasena, SMTP, Puerto,BBC
	 FROM TA_Correo AS C
	 INNER JOIN S_CorreoServidor AS S ON S.IdCorreoServidor=C.IdServidor
	 WHERE IdCorreo =@IdCorreo 

END

