CREATE TABLE [dbo].[EP_EvaluacionProveedorDetalle] (
    [IdEvaluacionProveedorDetalle] INT IDENTITY (1, 1) NOT NULL,
    [IdConceptoEvaluar]            INT NULL,
    [Ponderacion]                  INT NULL,
    [IdEvaluacionCabecera]         INT NULL,
    CONSTRAINT [PK_EP_EvaluacionProveedorDetalle] PRIMARY KEY CLUSTERED ([IdEvaluacionProveedorDetalle] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_EP_EvaluacionProveedorDetalle_EP_EvaluacionProveedor] FOREIGN KEY ([IdEvaluacionCabecera]) REFERENCES [dbo].[EP_EvaluacionProveedor] ([IdEvaluacionProveedor])
);

