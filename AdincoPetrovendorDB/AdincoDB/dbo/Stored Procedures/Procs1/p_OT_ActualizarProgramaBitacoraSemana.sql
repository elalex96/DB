IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'p_OT_ActualizarProgramaBitacoraSemana'
    )
    DROP PROCEDURE p_OT_ActualizarProgramaBitacoraSemana;
GO
CREATE PROCEDURE p_OT_ActualizarProgramaBitacoraSemana
@pIdOTProgramaBitacoraSemana	int,
@pFechaRegistro	datetime,
@pComentarios	varchar(500)
as
BEGIN
	
	update [OT_ProgramaBitacoraSemana]
	set 
		Comentarios = @pComentarios
	where IdOTProgramaBitacoraSemana = @pIdOTProgramaBitacoraSemana;

END;