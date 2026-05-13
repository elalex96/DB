CREATE TABLE [dbo].[MM_LicitacionDetalle] (
    [IdLicitacionDetalle] INT IDENTITY (10000, 1) NOT NULL,
    [IdLicitacion]        INT NULL,
    CONSTRAINT [PK_MM_LicitacionDetalle] PRIMARY KEY CLUSTERED ([IdLicitacionDetalle] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MM_LicitacionDetalle_MM_Licitacion] FOREIGN KEY ([IdLicitacion]) REFERENCES [dbo].[MM_Licitacion] ([IdLicitacion])
);

