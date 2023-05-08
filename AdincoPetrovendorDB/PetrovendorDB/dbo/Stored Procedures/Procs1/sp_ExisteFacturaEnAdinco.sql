CREATE PROCEDURE dbo.sp_ExisteFacturaEnAdinco
(@IdAceptacionPedido INT)
AS
BEGIN
    DECLARE @IdFacturaPetrov INT,
            @UUID NVARCHAR(1000)

    SELECT @IdFacturaPetrov = af.IdFactura
    FROM dbo.MM_AceptacionFactura af
    WHERE af.IdAceptacionPedido = @IdAceptacionPedido

    SELECT @UUID = f.UUID
    FROM dbo.FI_Factura f
    WHERE f.IdFactura = @IdFacturaPetrov


    IF EXISTS (SELECT 1 FROM Adinco.dbo.FI_Factura WHERE UUID = @UUID)
        SELECT 1
    ELSE
        SELECT 0

END