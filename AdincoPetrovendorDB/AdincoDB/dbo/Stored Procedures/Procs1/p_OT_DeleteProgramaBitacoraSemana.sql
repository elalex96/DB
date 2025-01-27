IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'p_OT_DeleteProgramaBitacoraSemana'
    )
    DROP PROCEDURE p_OT_DeleteProgramaBitacoraSemana;
GO
CREATE PROCEDURE p_OT_DeleteProgramaBitacoraSemana
@pIdOTProgramaBitacoraSemana	int
as
BEGIN
	DELETE [OT_ProgramaBitacoraSemana]
	WHERE IdOTProgramaBitacoraSemana = @pIdOTProgramaBitacoraSemana
END

