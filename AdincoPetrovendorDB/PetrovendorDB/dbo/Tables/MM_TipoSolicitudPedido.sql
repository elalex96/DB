CREATE TABLE [dbo].[MM_TipoSolicitudPedido] (
    [IdTipoSolicitudPedido] INT            IDENTITY (10000, 1) NOT NULL,
    [TipoSolicitudPedido]   NVARCHAR (MAX) NULL,
    [SolPedType]            NVARCHAR (MAX) NULL,
    [Activo]                BIT            NULL,
    [TipoProcura]           NVARCHAR (250) NULL,
    [CreadoPor]             INT            NULL,
    [Creado]                DATETIME       NULL,
    CONSTRAINT [PK_MM_TipoSolicitudPedido] PRIMARY KEY CLUSTERED ([IdTipoSolicitudPedido] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

