-- =============================================
-- Author:		Manuel Cruz
-- Create date: 06-01-17
-- Description:	Devuelve a la parte Web el correo de los usuarios de acuerdo al parámetro resibido @IdTarea
				-- para mandar una respuesta que se determina por la Web
-- =============================================
CREATE PROCEDURE [dbo].[SP_TaRespuestaTarea] 
	-- Add the parameters for the stored procedure here
	@IdTarea INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT Us.Usuario FROM TaTarea T
	JOIN TaTareaAprobador TAp ON T.IdTarea = TAp.IdTarea
	JOIN AP_Usuario Us ON TAp.IdUsuario = Us.UsuarioID
	WHERE T.IdTarea = @IdTarea

END


