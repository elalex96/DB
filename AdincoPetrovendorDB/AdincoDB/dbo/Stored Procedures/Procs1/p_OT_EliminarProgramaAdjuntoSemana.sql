CREATE PROC p_OT_EliminarProgramaAdjuntoSemana
@pID INT
AS

	DELETE [OT_ProgramaAdjuntoSemana]
	WHERE id = @pID

