CREATE TABLE [dbo].[AP_PaginaLayout] (
    [idPagina]     INT            IDENTITY (10000, 1) NOT NULL,
    [NombrePagina] NVARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([idPagina] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

