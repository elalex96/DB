-- =============================================
-- Author:		Reyna Olvera
-- Create date: 10-08-2018
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[CO_ExtraeRutasContratos]
    
    @idContrato INT,
    @idUsuario INT = 0,
    @idpagina INT
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
        SELECT 1,
               URL
        FROM dbo.AP_NameLayoutImportacion
        WHERE idContrato = @idContrato
              AND idPagina = @idpagina;
    END;
    ELSE
    BEGIN
        DECLARE @NumeroC NVARCHAR(100);

        IF @idpagina = 10000 OR @idpagina=10003--Cromatografia
        BEGIN
            SELECT 0,
                   '~\Docs\FormatosLayout\Cromatografi\'
                   + REPLACE(
                                REPLACE(REPLACE(REPLACE(REPLACE(NumeroContrato, '/', ''), '*', ''), ':', ''), '\', ''),
                                '|',
                                ''
                            )
            FROM dbo.CO_Contrato
            WHERE IdContrato = @idContrato;
        END;
        ELSE IF @idpagina = 10001 --PD
        BEGIN
            SELECT 0,
                   '~\Docs\FormatosLayout\ProduccionD\'
                   + REPLACE(
                                REPLACE(REPLACE(REPLACE(REPLACE(NumeroContrato, '/', ''), '*', ''), ':', ''), '\', ''),
                                '|',
                                ''
                            )
            FROM dbo.CO_Contrato
            WHERE IdContrato = @idContrato;
        END;
        ELSE IF @idpagina = 10002 --PC
        BEGIN
            SELECT 0,
                   '~\Docs\FormatosLayout\ProduccionC\'
                   + REPLACE(
                                REPLACE(REPLACE(REPLACE(REPLACE(NumeroContrato, '/', ''), '*', ''), ':', ''), '\', ''),
                                '|',
                                ''
                            )
            FROM dbo.CO_Contrato
            WHERE IdContrato = @idContrato;
        END;
    END;

END;