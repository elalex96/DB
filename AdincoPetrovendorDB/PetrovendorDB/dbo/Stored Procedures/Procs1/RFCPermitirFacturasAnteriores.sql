USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'RFCPermitirFacturasAnteriores'
)
    DROP PROCEDURE RFCPermitirFacturasAnteriores;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[RFCPermitirFacturasAnteriores] 
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
                    FROM FacturasExcluirRestriccionAnioFiscal (NOLOCK)
                    WHERE UPPER(RFCOperadora) = UPPER(@RFC)
                          AND Activo = 1
						  AND FechaVigencia >= GETDATE()
						  AND AnioExclucion = YEAR(@FechaTimbrado)
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
