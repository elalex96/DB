CREATE TABLE [dbo].[CatCFDI_c_MetodoPago] (
    [IdMetodoPago]        INT            IDENTITY (1, 1) NOT NULL,
    [c_MetodoPago]        NVARCHAR (255) NULL,
    [Descripcion]         NVARCHAR (255) NULL,
    [Fechainiciovigencia] DATETIME       NULL,
    [Fechafinvigencia]    NVARCHAR (255) NULL
);

