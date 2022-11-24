-- =============================================
-- Author:	Daniel AC
-- Create date: <25/08/2022>
-- Description:	Optimización de sp
-- =============================================
CREATE procedure [dbo].[ME_ConsultarMatrizPorPedido] 
	@IdPedido INT
AS
BEGIN
	SELECT m.IdDocMatriz, m.NombreDoc, m.IdOperacion
	FROM dbo.TA_DocMatrizOperacion m  (NOLOCK)
	JOIN dbo.MM_PeticionOferta p   (NOLOCK)
	ON m.IdOperacion = p.IdSolicitudPedido
	WHERE p.IdPeticionOferta = @IdPedido
END