CREATE PROCEDURE Layout_RevisarInsercion
(
    @Fecha DATE,
    @NombreLayout NVARCHAR(250)
)
AS
BEGIN
    IF (LTRIM(RTRIM(LOWER(@NombreLayout))) = LOWER('Company Code'))
    BEGIN
        SELECT COUNT(1)
        FROM dbo.CGI_Layout
        WHERE YEAR(DocumentDate) = YEAR(@Fecha)
              AND MONTH(DocumentDate) = MONTH(@Fecha);
    END;
    IF (LTRIM(RTRIM(LOWER(@NombreLayout))) = LOWER('ID VENDOR'))
    BEGIN
        SELECT COUNT(1)
        FROM dbo.Gastos_Layout
        WHERE YEAR(FechaClearing) = YEAR(@Fecha)
              AND MONTH(FechaClearing) = MONTH(@Fecha);
    END;
END;