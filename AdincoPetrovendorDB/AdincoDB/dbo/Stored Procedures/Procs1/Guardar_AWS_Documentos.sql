CREATE PROCEDURE  [dbo].[Guardar_AWS_Documentos]
	@NombreArchivo VARCHAR(250),
    @Folder VARCHAR(100),
    @UUIDAmazon VARCHAR(500),
    @Meta VARCHAR(50)='',
    @Bucket VARCHAR(50),
    @CreadoPor INT,
	@IdContrato INT = 0,
	@FueModificado BIT = 0
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
		CreadoEl,
		IdContrato,
		Activo
    )
    VALUES(@AWSDocumentoId, @Bucket, @Folder, @UUIDAmazon, @NombreArchivo, @Meta, @CreadoPor, GETDATE(), @IdContrato, 1);

	IF(@FueModificado = 1)
	BEGIN
		UPDATE AWS_Documentos 
		SET ModificadoEl = GETDATE(),
		ModificadoPor = @CreadoPor
		WHERE AWSDocumentoId = @AWSDocumentoId
	END

	SELECT @AWSDocumentoId


END




