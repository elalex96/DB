IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'p_OT_EliminarProgramaAdjunto'
    )
    DROP PROCEDURE p_OT_EliminarProgramaAdjunto;
GO
CREATE PROCEDURE p_OT_EliminarProgramaAdjunto
@pID INT
AS
BEGIN

	DELETE [OT_ProgramaAdjunto]
	WHERE id = @pID;

END