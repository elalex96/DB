CREATE TABLE [dbo].[AP_NameLayoutImportacion] (
    [idNameLayout] INT            IDENTITY (10000, 1) NOT NULL,
    [idContrato]   INT            NULL,
    [Nombre]       NVARCHAR (MAX) NULL,
    [URL]          NVARCHAR (MAX) NULL,
    [idPagina]     INT            NULL,
    FOREIGN KEY ([idContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    FOREIGN KEY ([idPagina]) REFERENCES [dbo].[AP_PaginaLayout] ([idPagina])
);

