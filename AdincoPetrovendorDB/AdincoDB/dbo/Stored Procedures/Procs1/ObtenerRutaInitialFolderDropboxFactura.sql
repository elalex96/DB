IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'ObtenerRutaInitialFolderDropboxFactura'
    )
    DROP PROCEDURE ObtenerRutaInitialFolderDropboxFactura;
GO
CREATE PROCEDURE [dbo].ObtenerRutaInitialFolderDropboxFactura 
    @IdFactura INT
AS
BEGIN
    DECLARE 
        @Ruta VARCHAR(5000) = 'PASAPI Dropbox\00 Para PEMEX\GASTOS ELEGIBLES\2 INFORMES DE GE ORIGINALES\##ANIO_MES## INFORME GE\',
        @FechaFactura DATE,
        @ReceptorRFC VARCHAR(50),
        @AnioMes CHAR(7);

    SELECT 
        @FechaFactura = FechaTimbrado,
        @ReceptorRFC = Receptor
    FROM FI_Factura  (NOLOCK)
    WHERE IdFactura = @IdFactura;

    SET @AnioMes = CONVERT(CHAR(7), @FechaFactura, 120);

    IF EXISTS (
        SELECT 1
        FROM APP_RelacionRutaDropboxFactura  (NOLOCK)
        WHERE IdFactura = @IdFactura
    )
    BEGIN
        SELECT *
        FROM APP_RelacionRutaDropboxFactura  (NOLOCK)
        WHERE IdFactura = @IdFactura;
    END
    ELSE
    BEGIN
       SELECT 0 as Id,REPLACE(@Ruta, '##ANIO_MES##', @AnioMes) AS Ruta,@IdFactura AS IdFactura;
    END
END
