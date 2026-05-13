CREATE PROCEDURE [dbo].[sp_AgregarConcepto]
(
    @IdFactura INT,
    @Descripcion NVARCHAR(MAX),
    @Cantidad FLOAT,
    @Unidad NVARCHAR(MAX),
    @ValorUnitario MONEY,
    @Importe MONEY,
    @NoIdentificacion NVARCHAR(MAX),
    @CreadoPor INT
)
AS
BEGIN
    INSERT INTO dbo.FI_CFDIConcepto
    (
        IdFactura,
        Descripcion,
        Cantidad,
        Unidad,
        ValorUnitario,
        Importe,
        NoIdentificacion,
        CreadoPor
    )
    VALUES
    (   @IdFactura,        -- IdFactura - int
        @Descripcion,      -- Descripcion - varchar(max)
        @Cantidad,         -- Cantidad - float
        @Unidad,           -- Unidad - nvarchar(max)
        @ValorUnitario,    -- ValorUnitario - money
        @Importe,          -- Importe - money
        @NoIdentificacion, -- NoIdentificacion - nvarchar(max)
        @CreadoPor         -- CreadoPor - int
    )
END