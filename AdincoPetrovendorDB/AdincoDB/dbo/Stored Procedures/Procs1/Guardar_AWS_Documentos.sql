CREATE PROCEDURE  Guardar_AWS_Documentos
	@NombreArchivo VARCHAR(250),
    @Folder VARCHAR(100),
    @UUIDAmazon VARCHAR(500),
    @Meta VARCHAR(50)='',
    @Bucket VARCHAR(50),
    @CreadoPor INT
AS    
BEGIN       
	DECLARE @AWSDocumentoId INT=0;

	SELECT @AWSDocumentoId = (MAX(AWSDocumentoId)+1) FROM AWS_Documentos;

    INSERT INTO AWS_Documentos
    (
		AWSDocumentoId,
		Bucket,
		Folder,
		UUIDAmazon,
		NombreArchivo,
		Meta,
		CreadoPor,
		CreadoEl
    )
    VALUES(@AWSDocumentoId, @Bucket, @Folder, @UUIDAmazon, @NombreArchivo, @Meta, @CreadoPor, GETDATE());

	SELECT @AWSDocumentoId
END




