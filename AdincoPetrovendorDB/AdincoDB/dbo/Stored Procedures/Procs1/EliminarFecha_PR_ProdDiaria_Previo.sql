CREATE PROCEDURE EliminarFecha_PR_ProdDiaria_Previo
    @IdContrato INT,
    @Fecha DATETIME
AS
BEGIN
    DELETE PR_ProdDiariaPozo_Previo
    FROM PR_ProdDiaria_Previo	
        INNER JOIN PR_BLOQUE	
            ON PR_ProdDiaria_Previo.Bloque = PR_BLOQUE.Id
               AND PR_BLOQUE.IdContrato = @IdContrato
        INNER JOIN PR_ProdDiariaPozo_Previo	
            ON PR_ProdDiaria_Previo.Id = PR_ProdDiariaPozo_Previo.ProdDiaria
    WHERE CAST(PR_ProdDiaria_Previo.Fecha AS DATE) = CAST(@Fecha AS DATE)

    DELETE PR_ProdDiaria_Previo
    FROM PR_ProdDiaria_Previo	
        INNER JOIN PR_BLOQUE	
            ON PR_ProdDiaria_Previo.Bloque = PR_BLOQUE.Id
               AND PR_BLOQUE.IdContrato = @IdContrato
    WHERE CAST(PR_ProdDiaria_Previo.Fecha AS DATE) = CAST(@Fecha AS DATE)

END

