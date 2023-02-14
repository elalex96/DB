CREATE PROCEDURE [dbo].[co_sp_InsertaArchivoLayoutGasto]
    @pAWSDocumentoId INT OUT,
    @pNombreArchivo VARCHAR(250),
    @pFolder VARCHAR(100),
    @pUUIDAmazon UNIQUEIDENTIFIER,
    @pMeta VARCHAR(50)='',
    @pBucket VARCHAR(50),
    @pCreadoPor INT,
    @IdContrato INT
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

	INSERT INTO CO_ArchivoLayoutGasto
	(
	ContratoId,
	AWSDocumentoId,
	CreadoEl,
	CreadoPor
	)
	VALUES (@IdContrato,@pAWSDocumentoId, GETDATE(),@pCreadoPor );

	SELECT @pAWSDocumentoId AS pAWSDocumentoId
END;