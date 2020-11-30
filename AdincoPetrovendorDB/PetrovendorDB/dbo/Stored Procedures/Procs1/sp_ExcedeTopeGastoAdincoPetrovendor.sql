CREATE PROCEDURE dbo.sp_ExcedeTopeGastoAdincoPetrovendor(@IdAceptacionPedido INT)
AS
     BEGIN
         DECLARE @IdFacturaPetrov INT, @UUID NVARCHAR(1000), @IdFacturaAdinco INT;
         SELECT @IdFacturaPetrov = af.IdFactura
         FROM dbo.MM_AceptacionFactura af
         WHERE af.IdAceptacionPedido = @IdAceptacionPedido;
         SELECT @UUID = f.UUID
         FROM dbo.FI_Factura f
         WHERE f.IdFactura = @IdFacturaPetrov;
         SELECT @IdFacturaAdinco = IdFactura
         FROM Adinco.dbo.FI_Factura
         WHERE UUID = @UUID;
         IF EXISTS
         (
             SELECT 1
             FROM Adinco.dbo.CO_Registro
             WHERE IdFactura = ISNULL(@IdFacturaAdinco, 0)
         )
             BEGIN
                 SELECT 1;
             END;
             ELSE
             BEGIN
                 SELECT 0;
             END;
     END;