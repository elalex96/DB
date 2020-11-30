CREATE PROCEDURE [dbo].[sp_JAObtenerIdSolPedxIdSolOferta] (@IdSolOferta INT)
AS
BEGIN
	SELECT IdSolicitudPedido FROM dbo.MM_PeticionOferta WHERE IdPeticionOferta = @IdSolOferta
END	
