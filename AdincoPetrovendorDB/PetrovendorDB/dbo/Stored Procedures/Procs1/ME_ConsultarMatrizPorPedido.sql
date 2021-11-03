
DROP PROCEDURE IF EXISTS ME_ConsultarMatrizPorPedido
GO
-- =============================================
-- Author:		<Luis David>
-- Create date: <01/11/2021>
-- Description:	<Reacomodo de tablas para optimización>
-- =============================================
CREATE procedure [dbo].[ME_ConsultarMatrizPorPedido] --12417
	@IdPedido INT
AS
BEGIN
	SELECT m.IdDocMatriz, m.NombreDoc, m.IdOperacion
	FROM dbo.TA_DocMatrizOperacion m
	INNER JOIN dbo.MM_PeticionOferta p 
	ON m.IdOperacion = p.IdSolicitudPedido
	WHERE p.IdPeticionOferta = @IdPedido
END
