CREATE TABLE [dbo].[CatCFDI_c_UsoCFDI] (
    [IdUsoCFDI]           INT            IDENTITY (1, 1) NOT NULL,
    [c_UsoCFDI]           NVARCHAR (255) NULL,
    [Descripcion]         NVARCHAR (255) NULL,
    [fisica]              NVARCHAR (255) NULL,
    [moral]               NVARCHAR (255) NULL,
    [Fechainiciovigencia] DATETIME       NULL,
    [Fechafinvigencia]    FLOAT (53)     NULL
);

