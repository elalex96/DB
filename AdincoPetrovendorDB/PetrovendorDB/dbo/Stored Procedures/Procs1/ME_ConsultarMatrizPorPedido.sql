
CREATE procedure [dbo].[ME_ConsultarMatrizPorPedido] --12417
	@IdPedido INT
AS
BEGIN
	SELECT m.IdDocMatriz, m.NombreDoc, m.IdOperacion
		FROM dbo.TA_DocMatrizOperacion m
		INNER JOIN dbo.MM_PeticionOferta p ON p.IdSolicitudPedido = m.IdOperacion
		WHERE p.IdPeticionOferta = @IdPedido
END


