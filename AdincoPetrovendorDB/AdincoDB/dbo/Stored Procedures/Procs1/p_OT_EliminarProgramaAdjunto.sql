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
@pID INT,
@UsuarioId INT NULL = 0,
@ContratoId INT NULL = 0
AS
BEGIN

	IF(@UsuarioId > 0 AND @ContratoId > 0)
	BEGIN
		INSERT INTO AP_BITACORA (Fecha,Tipo,Mensaje,Detalle,UsuarioId,ContratoId)
		SELECT GETDATE(),'Eliminación','Eliminación de documento de programa OT',
		CONCAT('Eliminación de documento de programa OT: ',IdOTSolicitud,' con AWSDocumentoId: ',AWSDocumentoId),
		@UsuarioId,
		@ContratoId
		FROM [OT_ProgramaAdjunto] (NOLOCK) WHERE Id = @pID;
	END;

	DELETE [OT_ProgramaAdjunto]
	WHERE id = @pID;

END