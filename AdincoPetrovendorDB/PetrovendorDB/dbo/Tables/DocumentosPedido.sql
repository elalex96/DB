CREATE TABLE [dbo].[DocumentosPedido] (
    [Id]              INT            IDENTITY (1, 1) NOT NULL,
    [IdPedido]        INT            NULL,
    [Version]         INT            NULL,
    [Carpeta]         NVARCHAR (MAX) NULL,
    [Identificador]   NVARCHAR (MAX) NULL,
    [Mime]            NVARCHAR (200) NULL,
    [Extension]       NVARCHAR (200) NULL,
    [NombreDocumento] NVARCHAR (MAX) NULL,
    [CreadoPor]       INT            NULL,
    [CreadoEl]        DATETIME       NULL,
    [ModificadoEl]    DATETIME       NULL,
    [ModificadoPor]   INT            NULL,
    [Activo]          BIT            NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_DocumentosPedido_MM_Pedido] FOREIGN KEY ([IdPedido]) REFERENCES [dbo].[MM_Pedido] ([IdPedido])
);

