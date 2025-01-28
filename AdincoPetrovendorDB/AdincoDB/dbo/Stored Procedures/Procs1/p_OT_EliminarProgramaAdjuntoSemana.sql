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
@pID INT,
@UsuarioId INT NULL = 0,
@ContratoId INT NULL= 0
AS
BEGIN

	IF(@UsuarioId > 0 AND @ContratoId > 0)
	BEGIN
		INSERT INTO AP_BITACORA (Fecha,Tipo,Mensaje,Detalle,UsuarioId,ContratoId)
		SELECT GETDATE(),'Eliminación','Eliminación de documento perteneciente a una semana de un programa OT',
		CONCAT('Eliminación de documento de la OTSolicitudMaterial:', IdOTSolicitudMaterial ,
		', semana con fecha inicio: ',CONVERT(VARCHAR, FechaInicioSemana, 103),
		' con fecha fin: ',CONVERT(VARCHAR, FechaFinSemana, 103), ', AWSDocumentoId: ',AWSDocumentoId),
		@UsuarioId,
		@ContratoId
		FROM [OT_ProgramaAdjuntoSemana] (NOLOCK) WHERE Id = @pID;
	END


	DELETE [OT_ProgramaAdjuntoSemana]
	WHERE id = @pID
END

