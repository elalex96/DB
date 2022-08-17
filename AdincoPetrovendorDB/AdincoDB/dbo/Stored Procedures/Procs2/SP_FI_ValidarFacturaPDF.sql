-- =============================================
-- Author:		Marcos Garcia
-- Create date: 04-09-2020
-- Description:	Validación de UUID para registrar el pdf
-- =============================================   
-- Modificado Por:	Neri Garcia
-- Fecha:			17 de Agosto del 2022
-- Descripción:		Eliminación de código comentado, agregado de (NOLOCK), se quitan VARCHAR (MAX)
-- =============================================
-- [dbo].[SP_FI_ValidarFacturaPDF] 'carpeta/carpeta1/7DEAE730-A66C-45D1-A0FE-958F09F4CF4207.PDF',0,0
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ValidarFacturaPDF]
    @fileName VARCHAR(MAX),
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    /**/
    DECLARE @UUID VARCHAR(1000);
    DECLARE @Texto VARCHAR(1000);
    /**/
    IF CHARINDEX('/', @fileName) >= 1
    BEGIN
        SET @Texto =
        (
            SELECT REPLACE(
                              @fileName,
                              REVERSE(SUBSTRING(REVERSE(@fileName), CHARINDEX('/', REVERSE(@fileName)) + 0, 200)),
                              ''
                          )
        );
        SET @UUID =
        (
            SELECT SUBSTRING(@Texto, 0, LEN(@Texto) - 3)
        );
    END;
    /**/
    ELSE
    BEGIN
        SET @UUID =
        (
            SELECT SUBSTRING(@fileName, 0, LEN(@fileName) - 3)
        );
    END;
    /**/
    IF EXISTS
    (
        SELECT FI_Factura.IdFactura
        FROM FI_Factura (NOLOCK)
        WHERE FI_Factura.UUID = @UUID
    )
    BEGIN
        SELECT FI_Factura.IdFactura
        FROM FI_Factura (NOLOCK)
        WHERE FI_Factura.UUID = @UUID;
    END;
END;