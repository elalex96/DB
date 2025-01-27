IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'p_OT_EliminarProgramaAdjuntoSemana'
    )
    DROP PROCEDURE p_OT_EliminarProgramaAdjuntoSemana;
GO
CREATE PROCEDURE p_OT_EliminarProgramaAdjuntoSemana
@pID INT
AS
BEGIN
	DELETE [OT_ProgramaAdjuntoSemana]
	WHERE id = @pID
END

