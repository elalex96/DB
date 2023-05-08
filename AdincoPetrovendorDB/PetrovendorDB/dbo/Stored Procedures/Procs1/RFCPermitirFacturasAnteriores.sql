CREATE PROC RFCPermitirFacturasAnteriores 
(
    @RFC NVARCHAR(MAX),
    @FechaTimbrado DATETIME
)
AS
BEGIN
	DECLARE @ANIO_FISCAL INT = YEAR(GETDATE())
	IF (YEAR(GETDATE()) = 2019)  
    BEGIN  
        SELECT 0  
    END  
	ELSE
    BEGIN
        IF (YEAR(@FechaTimbrado) = @ANIO_FISCAL)
        BEGIN
            SELECT 1
        END
        ELSE
        BEGIN
            IF (YEAR(@FechaTimbrado) < @ANIO_FISCAL)
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