CREATE PROCEDURE [dbo].[PR_sp_InsertarArchivoCromatografia]
    @pAWSDocumentoId INT OUT,
    @pNombreArchivo VARCHAR(250),
    @pFolder VARCHAR(100),
    @pUUIDAmazon UNIQUEIDENTIFIER,
    @pMeta VARCHAR(50)='',
    @pBucket VARCHAR(50),
    @pCreadoPor INT,
    @IdContrato INT,
	@Anio INT,
	@Mes INT,
	@CromatografiaId INT
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
    VALUES(@AWSDocumentoId, @pBucket, @pFolder, @pUUIDAmazon, @pNombreArchivo, @pMeta, @pCreadoPor, GETDATE());

    SET @pAWSDocumentoId = @AWSDocumentoId;

	INSERT INTO CO_CromatografiaArchivo
	(
	CromatografiaId,
	ContratoId,
	AWSDocumentoId,
	Anio,
	Mes,
	CreadoEl,
	CreadoPor
	)
	VALUES (@CromatografiaId,@IdContrato,@AWSDocumentoId, @Anio,@Mes,GETDATE(),@pCreadoPor )
END;
