
CREATE PROC p_OT_InsertarProgramaAdjunto
	@pIdOTSolicitud		INT,
	--@pNombreAdjunto	VARCHAR(250),
	--@pAdjunto			IMAGE,
	@pCreadoPor			VARCHAR(100),
	@pAWSDocumentoId	int
AS
begin
	DECLARE @id INT
    
	SELECT @id = ISNULL(MAX(ID),0) + 1
	FROM [OT_ProgramaAdjunto]
	
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
				)
end