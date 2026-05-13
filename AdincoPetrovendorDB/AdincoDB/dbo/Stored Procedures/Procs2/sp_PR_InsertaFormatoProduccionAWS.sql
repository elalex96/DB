CREATE PROCEDURE [dbo].[sp_PR_InsertaFormatoProduccionAWS]
    @pAWSDocumentoId INT OUT,
    @IdTipoFormato INT,
    @pNombreArchivo VARCHAR(250),
    @pFolder VARCHAR(100),
    @pUUIDAmazon UNIQUEIDENTIFIER,
    @pMeta VARCHAR(50)='',
    @pBucket VARCHAR(50),
    @pCreadoPor INT,
    @IdContrato INT
AS
BEGIN

    INSERT INTO PR_FormatoProduccionAWS
    (
        IdTipoFormato,
        IdContrato,
        Bucket,
        Folder,
        UUIDAmazon,
        NombreArchivo,
        Meta,
        CreadoPor,
        CreadoEl
    )
    VALUES
    (@IdTipoFormato, @IdContrato, @pBucket, @pFolder, @pUUIDAmazon, @pNombreArchivo, @pMeta, @pCreadoPor, GETDATE());

    SET @pAWSDocumentoId = @@IDENTITY;

END;

