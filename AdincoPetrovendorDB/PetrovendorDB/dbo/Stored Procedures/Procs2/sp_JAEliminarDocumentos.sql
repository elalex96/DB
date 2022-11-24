CREATE PROCEDURE [dbo].[sp_JAEliminarDocumentos] (@IdTopic INT)
AS
BEGIN
    DELETE dbo.JA_Documento
    WHERE IdTopic = @IdTopic
END
