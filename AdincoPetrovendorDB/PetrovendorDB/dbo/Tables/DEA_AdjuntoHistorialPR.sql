CREATE TABLE [dbo].[DEA_AdjuntoHistorialPR] (
    [IdAjuntoHistorialPr] INT            IDENTITY (1, 1) NOT NULL,
    [IdAjuntoPr]          INT            NULL,
    [IdSolicitudPedido]   INT            NULL,
    [IdProveedor]         INT            NULL,
    [ID_PR_Anterior]      NVARCHAR (MAX) NULL,
    [ID_PR_Nuevo]         NVARCHAR (MAX) NULL,
    [Comentario_Anterior] NVARCHAR (MAX) NULL,
    [CreadoPor]           INT            NULL,
    [CreadoEl]            DATETIME       NULL,
    [EditadoEl]           DATETIME       NULL,
    [EditadoPor]          INT            NULL,
    [EliminadoEl]         DATETIME       NULL,
    [EliminadoPor]        INT            NULL,
    [Activo]              BIT            NULL,
    [IsEliminado]         BIT            NULL,
    PRIMARY KEY CLUSTERED ([IdAjuntoHistorialPr] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

