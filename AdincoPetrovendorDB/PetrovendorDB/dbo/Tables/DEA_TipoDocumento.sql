CREATE TABLE [dbo].[DEA_TipoDocumento] (
    [IdTipoDocumento]     INT           NOT NULL,
    [NombreTipoDocumento] NVARCHAR (50) NULL,
    [Requerido]           BIT           NULL,
    PRIMARY KEY CLUSTERED ([IdTipoDocumento] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

