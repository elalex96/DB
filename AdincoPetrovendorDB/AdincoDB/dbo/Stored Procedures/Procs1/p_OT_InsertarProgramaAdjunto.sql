IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'p_OT_InsertarProgramaAdjunto'
    )
    DROP PROCEDURE p_OT_InsertarProgramaAdjunto;
GO
CREATE PROCEDURE p_OT_InsertarProgramaAdjunto
	@pIdOTSolicitud		INT,
	@pCreadoPor			VARCHAR(100),
	@pAWSDocumentoId	int
AS
begin
	DECLARE @id INT;
    
	SELECT @id = ISNULL(MAX(ID),0) + 1
	FROM [OT_ProgramaAdjunto] (NOLOCK);

	INSERT INTO [dbo].[OT_ProgramaAdjunto]
				(
					ID,		
					IdOTSolicitud,		
					CreadoPor,		
					CreadoEl,
					AWSDocumentoId
					)
			values
				(
					@id,
					@pIdOTSolicitud,		
					@pCreadoPor,	
					GETDATE(),
					@pAWSDocumentoId
				);
end

