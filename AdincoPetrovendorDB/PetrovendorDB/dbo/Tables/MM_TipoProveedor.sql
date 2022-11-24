CREATE TABLE [dbo].[MM_TipoProveedor] (
    [IdTipoProveedor] INT            IDENTITY (1, 1) NOT NULL,
    [TipoProveedor]   NVARCHAR (300) NULL,
    [CreadoEl]        DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdTipoProveedor] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

