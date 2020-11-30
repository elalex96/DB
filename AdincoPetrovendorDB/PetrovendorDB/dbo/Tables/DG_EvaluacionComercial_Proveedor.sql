CREATE TABLE [dbo].[DG_EvaluacionComercial_Proveedor] (
    [IdEvaluacionProveedor] INT            IDENTITY (1, 1) NOT NULL,
    [IdProveedorEvaluado]   INT            NULL,
    [IdProveedorEvaluador]  INT            NULL,
    [Evaluacion]            INT            NULL,
    [IdUsuarioEvaluador]    INT            NULL,
    [Resenia]               NVARCHAR (MAX) NULL,
    [FechaEvaluacion]       DATETIME       NULL,
    [ModificadoEl]          DATETIME       NULL,
    [ModificadoPor]         INT            NULL,
    CONSTRAINT [PK_DG_EvaluacionEstrellas_Proveedor] PRIMARY KEY CLUSTERED ([IdEvaluacionProveedor] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_DG_EvaluacionComercial_Proveedor_S_Proveedor] FOREIGN KEY ([IdProveedorEvaluado]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor]),
    CONSTRAINT [FK_DG_EvaluacionComercial_Proveedor_S_Proveedor1] FOREIGN KEY ([IdProveedorEvaluador]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor]),
    CONSTRAINT [FK_DG_EvaluacionComercial_Proveedor_S_Usuario] FOREIGN KEY ([IdUsuarioEvaluador]) REFERENCES [dbo].[S_Usuario] ([IdUsuario])
);

