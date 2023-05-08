CREATE PROCEDURE  EliminarReporteDiarioOperacionPorFecha
	@Fecha DATETIME,
	@IdContrato INT

AS    
BEGIN
	DELETE PR_ProdDiariaPozo_Previo
	FROM PR_ProdDiariaPozo_Previo	
	INNER JOIN PR_ProdDiaria_Previo
		ON PR_ProdDiariaPozo_Previo.ProdDiaria = PR_ProdDiaria_Previo.Id
	INNER JOIN PR_BLOQUE	
            ON PR_ProdDiaria_Previo.Bloque = PR_BLOQUE.Id
               AND PR_BLOQUE.IdContrato = @IdContrato
	WHERE PR_ProdDiariaPozo_Previo.Fecha = @Fecha


	DELETE PR_ProdDiaria_Previo
	FROM PR_ProdDiaria_Previo	
	INNER JOIN PR_BLOQUE	
            ON PR_ProdDiaria_Previo.Bloque = PR_BLOQUE.Id
               AND PR_BLOQUE.IdContrato = @IdContrato
	WHERE PR_ProdDiaria_Previo.Fecha = @Fecha
END


