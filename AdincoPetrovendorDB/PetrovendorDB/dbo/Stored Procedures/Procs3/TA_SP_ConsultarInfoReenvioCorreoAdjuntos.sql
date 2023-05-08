-- =============================================
-- Author:		Daniel AC
-- Create date: 26/08/2019
-- Description:	Consutla detalle de información de correo con adjuntos  
-- =============================================
CREATE PROCEDURE [dbo].[TA_SP_ConsultarInfoReenvioCorreoAdjuntos] --46164
@IdNotificacion INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		N.NombreArchivo AS NombreArchivo, 
		Adjunto
	FROM Adinco.dbo.S_NotificacionAdjunto N (NOLOCK) 	
	WHERE N.IdNotificacion = @IdNotificacion
	
END
