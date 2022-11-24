  
CREATE PROCEDURE [dbo].[SP_CO_PuntosEntregaContrato]
	@IdContrato INT = 0,
	@IdUsuario INT = 0
AS
BEGIN	
	SELECT PE.PuntoEntregaID, PE.Nombre
	FROM [dbo].[CO_PuntosdeEntregaContrato] PEO
		INNER JOIN [dbo].[CO_PuntosdeEntrega] PE 
			ON PEO.IdContrato = @IdContrato AND 
				PEO.PuntoEntregaID = PE.PuntoEntregaID
	ORDER BY PE.PuntoEntregaID ASC
END