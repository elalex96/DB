CREATE PROCEDURE Layout_RevisarExisteMesAnio
(
    @Fecha DATE,
    @NombreLayout NVARCHAR(250)
)
AS
BEGIN
    IF (LTRIM(RTRIM(LOWER(@NombreLayout))) = LOWER('Company Code'))
    BEGIN
        IF EXISTS
        (
            SELECT 1
            FROM dbo.CGI_Layout
            WHERE YEAR(DocumentDate) = YEAR(@Fecha)
                  AND MONTH(DocumentDate) = MONTH(@Fecha)
                  AND Activo = 1
        )
        BEGIN
            SELECT 1;
        END;
        ELSE
        BEGIN
            SELECT 0;
        END;
    END;
    IF (LTRIM(RTRIM(LOWER(@NombreLayout))) = LOWER('ID VENDOR'))
    BEGIN
        IF EXISTS
        (
            SELECT 1
            FROM dbo.Gastos_Layout
            WHERE YEAR(FechaClearing) = YEAR(@Fecha)
                  AND MONTH(FechaClearing) = MONTH(@Fecha)
                  AND Activo = 1
        )
        BEGIN
            SELECT 1;
        END;
        ELSE
        BEGIN
            SELECT 0;
        END;
    END;
END;