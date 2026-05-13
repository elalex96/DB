
-- =============================================
-- Author:		Neri del Angel
-- Create date: 08 de Diciembre del 2022
-- Description:	Se agrega metodo de obtencion de nombre reporte
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_ObtenNombreArchivoXtraReport]
    @Archivo VARCHAR(100) = '',
    @IdContrato INT = 0,
    @IdUsuario INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NumeroRegistros INT = 0,
            @NombreArchivo VARCHAR(100) = '',
            @Fecha DATE = GETDATE();

    SELECT @NumeroRegistros = COUNT(*)
    FROM CO_NombreArchivoXtraReport
    WHERE Archivo = @Archivo

    IF (@NumeroRegistros > 0)
    BEGIN
        SELECT TOP 1
            @NombreArchivo = NombreArchivo
        FROM CO_NombreArchivoXtraReport
        WHERE Archivo = @Archivo
    END
    ELSE
    BEGIN
        IF (@Archivo IN ( 'rpt_AmLayout_V2', 'rpt_AmLayout_V3' ))
        BEGIN
            SET @NombreArchivo = '424104804PTSinActividadD';

            SELECT @NombreArchivo = @NombreArchivo + CAST(YEAR(@Fecha) AS VARCHAR(10))

            SELECT @NombreArchivo = @NombreArchivo + CASE
                                                         WHEN CAST(MONTH(@Fecha) AS INT) < 10 THEN
                                                             '0' + CAST(MONTH(@Fecha) AS VARCHAR(10))
                                                         ELSE
                                                             CAST(MONTH(@Fecha) AS VARCHAR(10))
                                                     END

            SELECT @NombreArchivo = @NombreArchivo + CASE
                                                         WHEN CAST(DAY(@Fecha) AS INT) < 10 THEN
                                                             '0' + CAST(DAY(@Fecha) AS VARCHAR(10))
                                                         ELSE
                                                             CAST(DAY(@Fecha) AS VARCHAR(10))
                                                     END
        END
        ELSE
        BEGIN
            SET @NombreArchivo = @Archivo;
        END
    END

    SELECT @NombreArchivo AS NombreArchivo
END;