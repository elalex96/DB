
CREATE PROC RFCPermitirFacturasAnteriores
(
    @RFC NVARCHAR(MAX),
    @FechaTimbrado DATETIME
)
AS
BEGIN
    IF (YEAR(GETDATE()) = 2019)
    BEGIN
        SELECT 1
    END
    ELSE
    BEGIN
        IF (YEAR(GETDATE()) = 2020 AND YEAR(@FechaTimbrado) = 2020)
        BEGIN
            SELECT 1
        END
        ELSE
        BEGIN
            IF (YEAR(@FechaTimbrado) < 2020)
            BEGIN
                IF EXISTS
                (
                    SELECT 1
                    FROM FacturasExcluirRestriccionAnioFiscal
                    WHERE UPPER(RFCOperadora) = UPPER(@RFC)
                          AND Activo = 1
                )
                BEGIN
                    SELECT 1
                END
            END
            ELSE
            BEGIN
                SELECT 0
            END
        END
    END
END

