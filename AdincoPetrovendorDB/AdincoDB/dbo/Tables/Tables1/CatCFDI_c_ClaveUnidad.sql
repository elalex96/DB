CREATE TABLE [dbo].[CatCFDI_c_ClaveUnidad] (
    [IdUnidad]            INT            IDENTITY (1, 1) NOT NULL,
    [c_ClaveUnidad]       NVARCHAR (MAX) NULL,
    [Nombre]              NVARCHAR (MAX) NULL,
    [Descripcion]         NVARCHAR (MAX) NULL,
    [Nota]                NVARCHAR (MAX) NULL,
    [Fechainiciovigencia] DATE           NULL,
    [Fechafinvigencia]    DATE           NULL,
    [Simbolo]             NVARCHAR (MAX) NULL
);

