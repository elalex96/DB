CREATE TABLE [dbo].[EN_EntregablesRelacionados] (
    [IdRelacion]   INT NOT NULL,
    [IdEntregable] INT NOT NULL,
    [Activo]       BIT NULL,
    CONSTRAINT [PK_EN_EntregablesRelacionados] PRIMARY KEY CLUSTERED ([IdRelacion] ASC, [IdEntregable] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_EN_EntregablesRelacionados_EN_ENTREGABLE] FOREIGN KEY ([IdEntregable]) REFERENCES [dbo].[EN_Entregable] ([IdEntregable])
);

