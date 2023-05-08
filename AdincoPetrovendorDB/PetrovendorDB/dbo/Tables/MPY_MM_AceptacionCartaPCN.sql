CREATE TABLE [dbo].[MPY_MM_AceptacionCartaPCN] (
    [IdAceptacionCartaPCN] INT            IDENTITY (1, 1) NOT NULL,
    [IdAceptacionPedido]   INT            NULL,
    [IdDocumento]          INT            NULL,
    [CreadoPor]            INT            NULL,
    [CreadoEl]             DATETIME       NULL,
    [IdEstatus]            INT            NULL,
    [Activo]               BIT            NULL,
    [IdUsuarioEvaluador]   INT            NULL,
    [ComentarioEvaluador]  NVARCHAR (MAX) NULL,
    [FechaEvaluacion]      DATETIME       NULL,
    [ComentarioProveedor]  NVARCHAR (MAX) NULL,
    [Verificable]          BIT            NULL,
    [IdEstatusEliminado]   INT            NULL,
    [IdEliminado]          INT            NULL,
    [Editado]              BIT            NULL,
    [IdProceso]            INT            NULL,
    CONSTRAINT [PK_MPY_MM_AceptacionCartaPCN] PRIMARY KEY CLUSTERED ([IdAceptacionCartaPCN] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

