CREATE PROC p_OT_EliminarProgramaAdjunto
@pID INT
AS

	DELETE [OT_ProgramaAdjunto]
	WHERE id = @pID
