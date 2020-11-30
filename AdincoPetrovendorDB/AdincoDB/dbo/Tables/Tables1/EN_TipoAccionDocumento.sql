CREATE TABLE [dbo].[EN_TipoAccionDocumento] (
    [idTipoAccion] INT           IDENTITY (1, 1) NOT NULL,
    [NombreAccion] NVARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([idTipoAccion] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

