CREATE PROCEDURE [dbo].[sp_ObtenerParticipantesSolPed]
(
    @IdTopic INT,
    @IdSolPed INT
)
AS
BEGIN
    SELECT relPart.IdParticipante
    FROM dbo.JA_TopicAclaraciones topic
        INNER JOIN dbo.JA_RelacionParticipantes relPart
            ON topic.IdTopic = relPart.IdTopic
        INNER JOIN dbo.JA_Participantes parti
            ON parti.IdParticipante = relPart.IdParticipante
    WHERE topic.IdSolPed = @IdSolPed
          AND relPart.IdTopic = @IdTopic

END


