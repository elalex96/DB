CREATE PROC sp_OT_InsertarProgramaAdjunto
@pIdOTSolicitud INT,
@pNombreAdjunto VARCHAR(250),
@pAdjunto IMAGE,
@pCreadoPor VARCHAR(100)
AS

	DECLARE @id INT
    
	SELECT @id = ISNULL(MAX(ID),0) + 1
	FROM [OT_ProgramaAdjunto]
	
	INSERT INTO [dbo].[OT_ProgramaAdjunto](
		ID,		IdOTSolicitud,		NombreAdjunto,		Adjunto,		CreadoPor,		CreadoEl)
	SELECT @id,@pIdOTSolicitud,		@pNombreAdjunto,	@pAdjunto,		@pCreadoPor,	GETDATE()
	
