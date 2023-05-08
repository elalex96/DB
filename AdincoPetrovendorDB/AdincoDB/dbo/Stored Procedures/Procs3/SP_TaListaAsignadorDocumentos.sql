-- =============================================
-- Author:		Manuel Cruz
-- Create date: 10-01-17
-- Description:	Muestra en la parte Web la lista del nombre de usuario y los docuementos que adjunta el Asignador
				-- al momento de crear la tarea 
-- =============================================
CREATE PROCEDURE [dbo].[SP_TaListaAsignadorDocumentos] 

@IdTarea int,
@IdUsuario int

AS
BEGIN

	SELECT NombreDocumento AS Text, RutaDocumento AS Value 
	FROM TaDocumento D
	INNER JOIN TaTareaDocumento TD ON TD.IdDocumento = D.IdDocumento
	INNER JOIN TaTarea T ON T.IdTarea = TD.IdTarea 
	INNER JOIN TaTareaAsignador TA ON TA.IdUsuario = TD.IdUsuario
	WHERE TD.IdTarea = @IdTarea AND TD.IdUsuario = @IdUsuario AND TA.IdTarea = @IdTarea AND TD.IdTipoUsuario = 2

END


