-- =============================================
-- Author:		Marcos Garcia
-- Create date: 04-09-2020
-- Description:	Validación de UUID para registrar el pdf
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ValidarFacturaPDF] 
-- =============================================
-- [dbo].[SP_FI_ValidarFacturaPDF] 'carpeta/carpeta1/7DEAE730-A66C-45D1-A0FE-958F09F4CF4207.PDF',0,0
-- =============================================
@fileName   VARCHAR(MAX), 
@IdContrato INT, 
@IdUsuario  INT
AS
    BEGIN
        -- SET NOCOUNT ON added to prevent extra result sets from
        -- interfering with SELECT statements.
        DECLARE @UUID VARCHAR(MAX);
        DECLARE @Texto VARCHAR(MAX);
        --
        IF CHARINDEX('/', @fileName) >= 1
            BEGIN
                SET @Texto =
                (
                    SELECT REPLACE(@fileName, REVERSE(SUBSTRING(REVERSE(@fileName), CHARINDEX('/', REVERSE(@fileName)) + 0, 200)), '')
                );
                SET @UUID =
                (
                    SELECT SUBSTRING(@Texto, 0, LEN(@Texto) - 3)
                );
            END;
            ELSE
            BEGIN
                SET @UUID =
                (
                    SELECT SUBSTRING(@fileName, 0, LEN(@fileName) - 3)
                );
            END;
        --
        IF EXISTS
        (
            SELECT IdFactura
            FROM dbo.FI_Factura
            WHERE UUID = @UUID
        )
            BEGIN
                SELECT IdFactura
                FROM dbo.FI_Factura
                WHERE UUID = @UUID;
            END;
    END;