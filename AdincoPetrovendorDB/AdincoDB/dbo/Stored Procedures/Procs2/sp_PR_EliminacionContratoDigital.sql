
CREATE PROCEDURE [dbo].[sp_PR_EliminacionContratoDigital]
    @pAWSDocumentoId INT
AS
BEGIN
    SET NOCOUNT ON;
	
	DELETE CO_ContratoPDF
    WHERE AWSDocumentoId = @pAWSDocumentoId;

    DELETE AWS_Documentos
    WHERE AWSDocumentoId = @pAWSDocumentoId;

END;

