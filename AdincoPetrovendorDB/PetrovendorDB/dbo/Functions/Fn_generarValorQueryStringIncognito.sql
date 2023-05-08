CREATE FUNCTION dbo.Fn_generarValorQueryStringIncognito()
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @Posibles NVARCHAR(800) = N'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890',
            @Index INT,
            @Contador INT = 1,
            @Retorno NVARCHAR(MAX)

    WHILE (@Contador <= 8)
    BEGIN
        SELECT @Index = FLOOR((SELECT Value FROM vw_getRANDValue) * (62 - 1) + 1)

        SET @Retorno = ISNULL(@Retorno, '') + SUBSTRING(@Posibles, @Index, 1)

        SET @Contador += 1
    END

    RETURN @Retorno

END
