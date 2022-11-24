-- =============================================
-- Author:		Manuel Cruz
-- Create date: 10-01-17
-- Description:	Muestra en la parte Web la lista del nombre de usuario y los docuementos que adjunta el Aprobador
				-- al momento de evaluar la tarea 
-- =============================================
CREATE PROCEDURE [dbo].[SP_TaListaAprobadorDocumentos] 
	-- Add the parameters for the stored procedure here
	@IdTarea int

AS
BEGIN

	SET NOCOUNT ON;

	SELECT Us.Nombre AS Nombre, D.NombreDocumento AS Text, D.RutaDocumento AS Value 
	FROM TaDocumento D
	JOIN TaTareaDocumento TD ON TD.IdDocumento = D.IdDocumento
	JOIN TaTarea T ON T.IdTarea = TD.IdTarea 
	JOIN TaTareaAprobador TA ON TA.IdUsuario = TD.IdUsuario
	JOIN AP_Usuario Us ON TA.IdUsuario = Us.UsuarioID
	WHERE TD.IdTarea = @IdTarea AND TA.IdTarea = @IdTarea AND TD.IdTipoUsuario = 1

END


