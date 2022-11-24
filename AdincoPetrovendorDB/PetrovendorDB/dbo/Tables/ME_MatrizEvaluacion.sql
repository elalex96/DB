CREATE TABLE [dbo].[ME_MatrizEvaluacion] (
    [IdMatrizEvaluacion]   INT           IDENTITY (1, 1) NOT NULL,
    [Nombre]               VARCHAR (MAX) NULL,
    [Descripcion]          VARCHAR (MAX) NULL,
    [CreadoEl]             SMALLDATETIME NOT NULL,
    [CreadoPor]            INT           NOT NULL,
    [IdProveedorEvaluador] INT           NOT NULL,
    [IdTipoEvaluacion]     INT           NOT NULL,
    [Activo]               BIT           NULL,
    CONSTRAINT [PK_ME_MatrizEvaluacion] PRIMARY KEY CLUSTERED ([IdMatrizEvaluacion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

