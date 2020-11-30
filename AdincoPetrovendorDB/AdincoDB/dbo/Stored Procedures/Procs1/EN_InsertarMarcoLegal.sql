CREATE PROCEDURE [dbo].[EN_InsertarMarcoLegal]
    @MarcoLegal VARCHAR(MAX),
    @idUsuario INT,
    @idContrato INT,
	@activo bit
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @count INT = 0;

    SELECT @count = COUNT(1)
    FROM dbo.EN_MarcoLegal
    WHERE MarcoLegal = @MarcoLegal;

    IF (@count = 0)
    BEGIN
        INSERT INTO EN_MarcoLegal (MarcoLegal, IsInterno, CreadoPor, CreadoEn, Activo, BITJOA)
        VALUES (@MarcoLegal, 0, @idUsuario, GETDATE(), @activo, 0);
    END;
END;