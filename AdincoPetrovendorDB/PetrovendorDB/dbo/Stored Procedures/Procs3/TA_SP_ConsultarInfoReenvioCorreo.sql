-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE TA_SP_ConsultarInfoReenvioCorreo
@IdNotificacion INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT  
	N.Para,
	N.Asunto,
	N.Mensaje,
	EN.EnviadoPor,
	N.De,
	EN.IdCorreo,
	EN.IdIdentificacion
	FROM Adinco.dbo.S_Notificacion N (NOLOCK)
	INNER JOIN dbo.TA_EnvioCorreo EN
	ON EN.IdEnvioAdinco = N.IdNotificacion
	WHERE N.IdNotificacion = @IdNotificacion

END