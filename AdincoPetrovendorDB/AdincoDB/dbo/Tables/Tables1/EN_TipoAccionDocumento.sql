CREATE TABLE [dbo].[EN_TipoAccionDocumento] (
    [idTipoAccion] INT           IDENTITY (1, 1) NOT NULL,
    [NombreAccion] NVARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([idTipoAccion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

