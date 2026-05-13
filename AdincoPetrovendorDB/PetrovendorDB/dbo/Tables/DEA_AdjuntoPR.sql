CREATE TABLE [dbo].[DEA_AdjuntoPR] (
    [IdAjuntoPr]        INT            IDENTITY (1, 1) NOT NULL,
    [IdSolicitudPedido] INT            NULL,
    [IdDocumento]       INT            NULL,
    [IdProveedor]       INT            NULL,
    [Comentario]        NVARCHAR (MAX) NULL,
    [CreadoPor]         INT            NULL,
    [CreadoEl]          DATETIME       NULL,
    [EditadoEl]         DATETIME       NULL,
    [EditadoPor]        INT            NULL,
    [EliminadoEl]       DATETIME       NULL,
    [EliminadoPor]      INT            NULL,
    [Activo]            BIT            NULL,
    [IsEliminado]       BIT            NULL,
    [ID_PR]             NVARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([IdAjuntoPr] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

