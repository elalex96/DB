CREATE TABLE [dbo].[CatCFDI_c_RegimenFiscal] (
    [IdRegimenfiscal]     INT            IDENTITY (1, 1) NOT NULL,
    [c_RegimenFiscal]     FLOAT (53)     NULL,
    [Descripcion]         NVARCHAR (255) NULL,
    [Fisica]              NVARCHAR (255) NULL,
    [Moral]               NVARCHAR (255) NULL,
    [Fechainiciovigencia] DATETIME       NULL,
    [Fechafinvigencia]    FLOAT (53)     NULL
);

