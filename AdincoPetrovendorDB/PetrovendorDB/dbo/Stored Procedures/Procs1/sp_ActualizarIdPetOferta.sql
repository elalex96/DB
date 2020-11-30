CREATE PROCEDURE [dbo].[sp_ActualizarIdPetOferta]
(
    @IdTopic INT,
    @IdSolped INT,
	@IdPetOferta INT
)
AS
BEGIN
	UPDATE dbo.JA_TopicAclaraciones SET IdOferta = @IdPetOferta
	WHERE IdTopic = @IdTopic AND IdSolPed = @IdSolped
END	

