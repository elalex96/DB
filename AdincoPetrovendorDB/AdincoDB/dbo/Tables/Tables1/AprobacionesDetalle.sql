CREATE TABLE [dbo].[AprobacionesDetalle] (
    [IdAprobacionDetalle] INT NOT NULL,
    [IdAprobacion]        INT NULL,
    [IdRol]               INT NULL,
    [Aprobado]            BIT NULL,
    [Activo]              BIT NULL,
    CONSTRAINT [PK_AprobacionesDetalle] PRIMARY KEY CLUSTERED ([IdAprobacionDetalle] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AprobacionesDetalle_Aprobaciones] FOREIGN KEY ([IdAprobacion]) REFERENCES [dbo].[Aprobaciones] ([IdAprobacion])
);

