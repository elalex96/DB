CREATE TABLE [dbo].[SP_EP_EvaluacionCalidad] (
    [IdEvaluacionProveedor] INT      IDENTITY (1, 1) NOT NULL,
    [IdProveedorEvaluado]   INT      NULL,
    [IdEvaluador]           INT      NULL,
    [IdPedido]              INT      NULL,
    [FechaRegistro]         DATETIME NULL,
    [IsActivo]              BIT      NULL,
    [TotalDePuntos]         INT      NULL,
    CONSTRAINT [PK_SP_EP_EvaluacionCalidad] PRIMARY KEY CLUSTERED ([IdEvaluacionProveedor] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

