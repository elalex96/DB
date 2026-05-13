CREATE TABLE [dbo].[PR_ProdDiariaEstacion] (
    [Id]                 INT             IDENTITY (1, 1) NOT NULL,
    [ProdDiaria]         INT             NOT NULL,
    [Fecha]              DATETIME        NULL,
    [Estacion]           INT             NOT NULL,
    [BombeoRealizado]    DECIMAL (24, 8) CONSTRAINT [DF_ProdDiariaEstacion_BombeoRealizado] DEFAULT ((0)) NOT NULL,
    [BombeoRecibido]     DECIMAL (24, 8) CONSTRAINT [DF_ProdDiariaEstacion_BombeoRecibido] DEFAULT ((0)) NOT NULL,
    [AcarreoRecibido]    DECIMAL (24, 8) CONSTRAINT [DF_ProdDiariaEstacion_AcarreoRecibido] DEFAULT ((0)) NOT NULL,
    [ExistenciaAnterior] DECIMAL (24, 8) CONSTRAINT [DF_ProdDiariaEstacion_ExistenciaAnterior] DEFAULT ((0)) NOT NULL,
    [ExistenciaActual]   DECIMAL (24, 8) CONSTRAINT [DF_ProdDiariaEstacion_ExistenciaActual] DEFAULT ((0)) NOT NULL,
    [ProduccionTeorica]  DECIMAL (24, 8) CONSTRAINT [DF_ProdDiariaEstacion_ProduccionTeorica] DEFAULT ((0)) NOT NULL,
    [ProduccionReal]     DECIMAL (24, 8) CONSTRAINT [DF_ProdDiariaEstacion_ProduccionReal] DEFAULT ((0)) NOT NULL,
    [ProduccionAlocada]  DECIMAL (24, 8) CONSTRAINT [DF_ProdDiariaEstacion_ProduccionAlocada] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_PR_ProdDiariaEstacion] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ProdDiariaEstacion_Estacion] FOREIGN KEY ([Estacion]) REFERENCES [dbo].[PR_Estacion] ([Id]),
    CONSTRAINT [FK_ProdDiariaEstacion_ProdDiaria] FOREIGN KEY ([ProdDiaria]) REFERENCES [dbo].[PR_ProdDiaria] ([Id])
);

