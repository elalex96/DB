CREATE TABLE [dbo].[MM_TipoSolicitudPedido] (
    [IdTipoSolicitudPedido] INT            IDENTITY (10000, 1) NOT NULL,
    [TipoSolicitudPedido]   NVARCHAR (MAX) NULL,
    [SolPedType]            NVARCHAR (MAX) NULL,
    [Activo]                BIT            NULL,
    CONSTRAINT [PK_MM_TipoSolicitudPedido] PRIMARY KEY CLUSTERED ([IdTipoSolicitudPedido] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

