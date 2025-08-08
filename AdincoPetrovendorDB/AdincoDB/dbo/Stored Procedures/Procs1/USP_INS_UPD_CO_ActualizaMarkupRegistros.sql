USE Adinco
GO
IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_INS_AWS_RegistraArchivo'
    )
    DROP PROCEDURE USP_INS_AWS_RegistraArchivo;
GO
CREATE PROCEDURE [dbo].[USP_INS_AWS_RegistraArchivo]
    @pAWSDocumentoId INT             OUT,
    @pNombreArchivo  VARCHAR(250),
    @pFolder         VARCHAR(100),
    @pUUIDAmazon     UNIQUEIDENTIFIER,
    @pMeta           VARCHAR(50)     = '',
    @pBucket         VARCHAR(50),
    @CreadoPor       INT,
    @IdContrato      INT
AS
    BEGIN
        DECLARE @AWSDocumentoId INT = 0;

        SELECT
            @AWSDocumentoId = (MAX(AWSDocumentoId) + 1)
        FROM
            AWS_Documentos;

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
        VALUES
            (
                @AWSDocumentoId, @pBucket, @pFolder, @pUUIDAmazon, @pNombreArchivo, @pMeta, @CreadoPor, GETDATE()
            );
        SET @pAWSDocumentoId = @AWSDocumentoId;
    END;
