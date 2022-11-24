CREATE TABLE [dbo].[ME_ResultadoMatriz] (
    [IdResultadoMatriz]   INT IDENTITY (1, 1) NOT NULL,
    [IdProveedorEvaluado] INT NOT NULL,
    [IdMatrizEvaluacion]  INT NOT NULL,
    [Resultado]           INT NOT NULL,
    [IdPedido]            INT NULL,
    CONSTRAINT [PK_ME_ResultadoMatriz] PRIMARY KEY CLUSTERED ([IdResultadoMatriz] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ME_ResultadoMatriz_ME_MatrizEvaluacion] FOREIGN KEY ([IdMatrizEvaluacion]) REFERENCES [dbo].[ME_MatrizEvaluacion] ([IdMatrizEvaluacion]),
    CONSTRAINT [FK_ME_ResultadoMatriz_S_Proveedor] FOREIGN KEY ([IdProveedorEvaluado]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor])
);

