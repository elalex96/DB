-- =============================================
-- Author:		<Jose Roman>
-- Create date: <16-08-2018>
-- Description:	<Se consultan los datos de auntentificacion para el servisio Twilio>
-- =============================================

create PROCEDURE SMS_SP_ConsultarDatosTwilio	
AS
BEGIN
	SELECT 
		AccountSid,
		AuthToken,
		Telefono
	FROM dbo.SMS_Twilio
	WHERE Activo = 1
END