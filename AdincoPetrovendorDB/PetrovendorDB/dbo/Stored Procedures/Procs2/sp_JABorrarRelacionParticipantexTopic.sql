CREATE PROCEDURE [dbo].[sp_JABorrarRelacionParticipantexTopic] (@IdTopic INT)
AS
BEGIN

    DELETE dbo.JA_RelacionParticipantes
    WHERE IdTopic = @IdTopic

END
