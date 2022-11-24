-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TA_SP_ReenviarCorreos]
@IdNotificacion INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE Adinco.dbo.S_Notificacion WITH (ROWLOCK)
	SET 
	Enviada = 0
	WHERE 
	IdNotificacion = @IdNotificacion

	SELECT Enviado = 1

END