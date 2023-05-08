CREATE PROCEDURE ExisteFecha_PR_ProdDiaria_Previo
    @IdContrato INT,
    @Fecha DATETIME
AS
BEGIN
    IF EXISTS
    (
        SELECT 1
        FROM PR_ProdDiaria_Previo	(NOLOCK)
            INNER JOIN PR_BLOQUE	(NOLOCK)
                ON PR_ProdDiaria_Previo.Bloque = PR_BLOQUE.Id
                   AND PR_BLOQUE.IdContrato = @IdContrato
        WHERE CAST(PR_ProdDiaria_Previo.Fecha AS DATE) = CAST(@Fecha AS DATE)
    )
    BEGIN
        SELECT 1
    END
    ELSE
    BEGIN
        SELECT 0
    END
END

