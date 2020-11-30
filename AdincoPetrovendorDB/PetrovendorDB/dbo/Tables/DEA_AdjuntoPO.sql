CREATE TABLE [dbo].[DEA_AdjuntoPO] (
    [IdAdjuntoPO]        INT            IDENTITY (1, 1) NOT NULL,
    [IdPedido]           INT            NULL,
    [IdDocumento]        INT            NULL,
    [IdProveedor]        INT            NULL,
    [Comentario]         NVARCHAR (MAX) NULL,
    [CreadoPor]          INT            NULL,
    [CreadoEl]           DATETIME       NULL,
    [EditadoEl]          DATETIME       NULL,
    [EditadoPor]         INT            NULL,
    [EliminadoEl]        DATETIME       NULL,
    [EliminadoPor]       INT            NULL,
    [Activo]             BIT            NULL,
    [IsEliminado]        BIT            NULL,
    [ID_PO]              NVARCHAR (MAX) NULL,
    [CargadaManualmente] BIT            NULL,
    PRIMARY KEY CLUSTERED ([IdAdjuntoPO] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

