CREATE PROCEDURE dbo.sp_FI_InsertaConceptoFacturaAdinco
(
    @IdFactura INT,
    @Descripcion NVARCHAR(MAX),
    @Cantidad FLOAT,
    @Unidad NVARCHAR(MAX),
    @ValorUnitario MONEY,
    @Importe MONEY,
    @ClaveProdServ NVARCHAR(MAX),
    @ClaveUnidad NVARCHAR(MAX),
    @NoIdentificacion NVARCHAR(MAX),
    @Descuento MONEY
)
AS
BEGIN
    EXEC Adinco.dbo.sp_FI_InsertaConceptoFactura @IdFactura = @IdFactura,               -- int
                                                 @Descripcion = @Descripcion,           -- nvarchar(max)
                                                 @Cantidad = @Cantidad,                 -- float
                                                 @Unidad = @Unidad,                     -- nvarchar(max)
                                                 @ValorUnitario = @ValorUnitario,       -- money
                                                 @Importe = @Importe,                   -- money
                                                 @NoIdentificacion = @NoIdentificacion, -- nvarchar(max)
                                                 @ClaveProdServ = @ClaveProdServ,       -- nvarchar(50)
                                                 @ClaveUnidad = @ClaveUnidad,           -- nvarchar(50)
                                                 @Descuento = @Descuento                -- money


END