-- =============================================
-- Author:		Manuel Cruz
-- Create date: 13-01-17
-- Description:	Envia el parametro de la hora al servicio de Windows en que debe de comparar la hora del sistema 
				-- para enviar las notificaciones de acuerdo a su tipo, recordatorio, por vencer o vencida
				-- y para que cancele la tarea vencida
-- =============================================
CREATE PROCEDURE [dbo].[SP_TaEnviarHora]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT Hora FROM TaHoraNotificarTarea
	
	END


