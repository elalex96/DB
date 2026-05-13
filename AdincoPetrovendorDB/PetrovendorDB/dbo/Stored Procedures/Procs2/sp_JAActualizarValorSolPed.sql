CREATE PROCEDURE [dbo].[sp_JAActualizarValorSolPed]
(
    @IdTopic INT,
    @IdSolPed INT
)
AS
BEGIN
    --idTopic es el id de la junta agendada
    UPDATE JA_TopicAclaraciones
    SET IdSolPed = @IdSolPed
    WHERE IdTopic = @IdTopic
END
