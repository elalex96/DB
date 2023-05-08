-- =============================================
-- Author:		Reyna Olvera
-- Create date: 10-08-2018
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE CO_InsertaRutasContratos
    @idContrato INT,
    @idUsuario INT = 0,
    @idpagina INT,
    @URL NVARCHAR(MAX),
    @NombreArchivo NVARCHAR(MAX)
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @count INT;

    SELECT @count = COUNT(idNameLayout)
    FROM dbo.AP_NameLayoutImportacion
    WHERE idContrato = @idContrato
          AND idPagina = @idpagina;

    IF (@count >= 1)
    BEGIN
        UPDATE dbo.AP_NameLayoutImportacion
		SET Nombre=@NombreArchivo,
		URL=@URL
        WHERE idContrato = @idContrato
              AND idPagina = @idpagina;
    END;
    ELSE
    BEGIN

        INSERT INTO AP_NameLayoutImportacion
        (
            idContrato,
            Nombre,
            URL,
            idPagina
        )
        VALUES
        (@idContrato, @NombreArchivo, @URL, @idpagina);

    END;

END;