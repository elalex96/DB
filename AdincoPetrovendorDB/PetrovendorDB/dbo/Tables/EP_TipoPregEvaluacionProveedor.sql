CREATE TABLE [dbo].[EP_TipoPregEvaluacionProveedor] (
    [IdTipoPreguntaEvaluacion] INT            IDENTITY (1, 1) NOT NULL,
    [TipoPregunta]             NVARCHAR (300) NULL,
    CONSTRAINT [PK_EP_TipoPregEvaluacionProveedor] PRIMARY KEY CLUSTERED ([IdTipoPreguntaEvaluacion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

