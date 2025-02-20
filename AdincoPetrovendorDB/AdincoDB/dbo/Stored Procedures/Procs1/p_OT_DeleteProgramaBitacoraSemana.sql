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
@pIdOTProgramaBitacoraSemana	int,
@UsuarioId INT NULL = 0,
@ContratoId INT NULL = 0
as
BEGIN
	
	IF(@UsuarioId > 0 AND @ContratoId > 0)
	BEGIN
		INSERT INTO AP_BITACORA (Fecha,Tipo,Mensaje,Detalle,UsuarioId,ContratoId)
		SELECT GETDATE(),'Eliminación','Eliminación de bitácora de solicitud OT',
		CONCAT('Eliminación de bitácora de solicitud OT: ',IdOTSolicitud,', con semana : ',SemanaID,
		', Comentarios: ', Comentarios, ', CreadoPor: ', CreadoPor),
		@UsuarioId,
		@ContratoId
		FROM [OT_ProgramaBitacoraSemana] (NOLOCK) WHERE IdOTProgramaBitacoraSemana = @pIdOTProgramaBitacoraSemana;
	END;

	DELETE [OT_ProgramaBitacoraSemana]
	WHERE IdOTProgramaBitacoraSemana = @pIdOTProgramaBitacoraSemana
END

