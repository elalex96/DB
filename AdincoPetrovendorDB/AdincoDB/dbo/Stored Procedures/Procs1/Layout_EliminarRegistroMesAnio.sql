CREATE PROCEDURE Layout_EliminarRegistroMesAnio
(
    @Fecha DATE,
    @NombreLayout NVARCHAR(300)
)
AS
BEGIN
    IF (LTRIM(RTRIM(LOWER(@NombreLayout))) = LOWER('Company Code'))
    BEGIN
        DELETE dbo.CGI_Layout
        WHERE YEAR(DocumentDate) = YEAR(@Fecha)
              AND MONTH(DocumentDate) = MONTH(@Fecha);
    END;

    IF (LTRIM(RTRIM(LOWER(@NombreLayout))) = LOWER('ID VENDOR'))
    BEGIN
        DELETE dbo.Gastos_Layout
        WHERE YEAR(FechaClearing) = YEAR(@Fecha)
              AND MONTH(FechaClearing) = MONTH(@Fecha);
    END;
END;