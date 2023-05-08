CREATE TABLE [dbo].[CatCFDI_c_TipoDeComprobante] (
    [Idtcomprobante]      INT            IDENTITY (1, 1) NOT NULL,
    [Descripcion]         NVARCHAR (255) NULL,
    [Valormaximo]         NVARCHAR (255) NULL,
    [Fechainiciovigencia] DATETIME       NULL,
    [Fechafinvigencia]    NVARCHAR (255) NULL
);

