
CREATE PROC sp_ObtenerFacturaXml
(@IdFactura INT)
AS
BEGIN

    SELECT ArchivoXml
    FROM dbo.FI_ArchivoXml
    WHERE IdFactura = @IdFactura

END

