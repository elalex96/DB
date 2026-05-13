CREATE TABLE [dbo].[AD_HistorialActualizacionPedido] (
    [Id]                INT            IDENTITY (1, 1) NOT NULL,
    [IdPedido]          INT            NULL,
    [ComentarioEditado] NVARCHAR (MAX) NULL,
    [Responsable]       NVARCHAR (100) NULL,
    [Descripcion]       NVARCHAR (300) NULL,
    [TipoEdicion]       NVARCHAR (50)  NULL,
    [Fecha]             DATETIME       NULL,
    CONSTRAINT [PK_AD_HistorialActualizacionPedido] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

