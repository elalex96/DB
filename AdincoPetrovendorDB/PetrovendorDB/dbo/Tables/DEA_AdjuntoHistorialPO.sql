CREATE TABLE [dbo].[DEA_AdjuntoHistorialPO] (
    [IdAdjuntoHistorialPO] INT            IDENTITY (1, 1) NOT NULL,
    [IdAdjuntoPO]          INT            NULL,
    [IdDocumento]          INT            NULL,
    [ID_PO_Anterior]       NVARCHAR (MAX) NULL,
    [ID_PO_Nuevo]          NVARCHAR (MAX) NULL,
    [CargadaManualmente]   BIT            NULL,
    [IdProveedor]          INT            NULL,
    [Comentario]           NVARCHAR (MAX) NULL,
    [CreadoPor]            INT            NULL,
    [CreadoEl]             DATETIME       NULL,
    [EditadoEl]            DATETIME       NULL,
    [EditadoPor]           INT            NULL,
    [EliminadoEl]          DATETIME       NULL,
    [EliminadoPor]         INT            NULL,
    [Activo]               BIT            NULL,
    [IsEliminado]          BIT            NULL,
    PRIMARY KEY CLUSTERED ([IdAdjuntoHistorialPO] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

