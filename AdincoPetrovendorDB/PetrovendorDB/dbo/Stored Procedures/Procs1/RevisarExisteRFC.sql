CREATE PROCEDURE RevisarExisteRFC
@RFC NVARCHAR(MAX),
@IdProveedor INT
AS
BEGIN
    DECLARE @TablaRFC TABLE (RFC NVARCHAR(MAX), IdProveedor INT)
    DECLARE @Cantidad INT

    INSERT INTO @TablaRFC (RFC, IdProveedor)
    SELECT p.RFC,
           p.IdProveedor
    FROM dbo.S_Proveedor p
    WHERE p.Activo = 1


    UPDATE @TablaRFC
    SET RFC = @RFC
    WHERE IdProveedor = @IdProveedor

    SELECT @Cantidad = COUNT(1)
    FROM @TablaRFC
    WHERE UPPER(RFC) = UPPER(@RFC)

    IF ISNULL(@Cantidad, 0) > 1
    BEGIN
        SELECT 1 -- existe y se duplicaria no permitir el guardado
    END
    ELSE
    BEGIN
        SELECT 0 -- si permitir el guardado
    END

END



