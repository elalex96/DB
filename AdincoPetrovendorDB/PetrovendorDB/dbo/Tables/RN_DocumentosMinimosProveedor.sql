CREATE TABLE [dbo].[RN_DocumentosMinimosProveedor] (
    [Id]                INT IDENTITY (1, 1) NOT NULL,
    [IdSolicitudPedido] INT NULL,
    [IdTipoRegimen]     INT NULL,
    [IdTipoDocumento]   INT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

