-- =================================================================
-- Author:	Luis David
-- Create date: 27/09/2019
-- Description:	se agrega el bitjoa y nombreeningles para el issue 419
-- =================================================================
-- =================================================================
-- Author: Alexander Gomez
-- Create date: 20/06/2022
-- Description:	se agrega el Alias
-- =================================================================
CREATE PROCEDURE [dbo].[EN_InsertarMarcoLegal]
    @MarcoLegal VARCHAR(MAX),
    @idUsuario INT,
    @idContrato INT,
	@activo bit,
	@MarcoLegalIngles VARCHAR(MAX) = null,
	@BitJoa bit = null,
	@Alias VARCHAR(1000)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @count INT = 0;

    SELECT @count = COUNT(1)
    FROM dbo.EN_MarcoLegal
    WHERE MarcoLegal = @MarcoLegal;

    IF (@count = 0)
    BEGIN
        INSERT INTO EN_MarcoLegal 
				(MarcoLegal,		MarcoLegalIngles,	IsInterno, 
				CreadoPor,			CreadoEn,			Activo, 
				BITJOA, Alias)
        VALUES 
				(@MarcoLegal,		@MarcoLegalIngles,	0, 
				@idUsuario,			GETDATE(),			@activo, 
				@BitJoa,@Alias);
    END;
END;