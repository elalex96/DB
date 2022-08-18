-- =============================================
-- Author:		Marcos Garcia
-- Create date: 15-11-2019
-- Description:	Modificacion del SP_FI_ActualizarTransferencia 
--              para solo agragar la info. del Uploaded PDF en el GRID
-- =============================================
-- Modificado Por: Neri Garcia
-- Fecha: 11 de Agosto del 2022
-- Detalles: Agregado de NOLOCK
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ActualizarTransferenciaSoloPdf]
    @IdContrato INT,
    @PDF NVARCHAR(MAX),
    @IdUsuario INT,
    @IdTransfer INT,
    @pAWSDocumentId INT
AS
BEGIN
    SET NOCOUNT ON;
    -- 
    IF @PDF = ''
    BEGIN
        UPDATE FI_Transfer
        SET [ModificadoPor] = @IdUsuario,
            [ModificadoEn] = GETDATE(),
            AWSPDFId = CASE
                           WHEN isnull(@pAWSDocumentId, 0) > 0 THEN
                               @pAWSDocumentId
                           ELSE
                               AWSPDFId
                       END
        WHERE IdTransferencia = @IdTransfer
              AND IdContrato = @IdContrato;
    END;
    ELSE
    BEGIN
        DECLARE @AWSExistente INT = (
                                        SELECT dbo.FI_Transfer.AWSPDFId
                                        FROM dbo.FI_Transfer (NOLOCK)
                                        WHERE dbo.FI_Transfer.IdTransferencia = @IdTransfer
                                              AND dbo.FI_Transfer.AWSPDFId IS NOT NULL
                                    );
        IF @AWSExistente IS NOT NULL
        BEGIN
            UPDATE dbo.AWS_Documentos
            SET Reemplazado = 1
            WHERE AWSDocumentoId = @AWSExistente;
        END;
        UPDATE FI_Transfer
        SET [PDF] = @PDF,
            [ModificadoPor] = @IdUsuario,
            [ModificadoEn] = GETDATE(),
            AWSPDFId = CASE
                           WHEN isnull(@pAWSDocumentId, 0) > 0 THEN
                               @pAWSDocumentId
                           ELSE
                               AWSPDFId
                       END
        WHERE IdTransferencia = @IdTransfer
              AND IdContrato = @IdContrato;
    END;
    IF @@ERROR <> 0
        SELECT 'false' AS msj;
    ELSE
        SELECT 'true' AS msj;
END;