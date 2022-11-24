CREATE TABLE [dbo].[PR_ProdDiaria_Previo] (
    [Id]                  INT             IDENTITY (1, 1) NOT NULL,
    [Bloque]              INT             NOT NULL,
    [Fecha]               DATETIME        NOT NULL,
    [VolumenBombeado]     DECIMAL (24, 8) CONSTRAINT [DF_ProdDiaria_Previo_Bombeada] DEFAULT ((0)) NOT NULL,
    [VolumenMedido]       DECIMAL (24, 8) CONSTRAINT [DF_ProdDiaria_Previo_Medida] DEFAULT ((0)) NOT NULL,
    [VolumenReportado]    DECIMAL (24, 8) CONSTRAINT [DF_ProdDiaria_Previo_VolumenReportado] DEFAULT ((0)) NOT NULL,
    [DiferenciaVolumenBM] DECIMAL (24, 8) CONSTRAINT [DF_ProdDiaria_Previo_Diferencia] DEFAULT ((0)) NOT NULL,
    [DiferenciaVolumenMR] DECIMAL (24, 8) CONSTRAINT [DF_ProdDiaria_Previo_DiferenciaVolumenMR] DEFAULT ((0)) NULL,
    [FechaModificacion]   DATETIME        NOT NULL,
    [UsuarioModificacion] VARCHAR (200)   NOT NULL,
    [Estatus]             TINYINT         CONSTRAINT [DF_ProdDiaria_Previo_Estatus] DEFAULT ((0)) NOT NULL,
    [Algoritmo]           INT             CONSTRAINT [DF_ProdDiaria_Previo_Algoritmo] DEFAULT ((0)) NOT NULL,
    [Temperatura]         FLOAT (53)      NULL,
    CONSTRAINT [PK_PR_ProdDiaria_Previo] PRIMARY KEY NONCLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ProdDiaria_Previo_Bloque] FOREIGN KEY ([Bloque]) REFERENCES [dbo].[PR_Bloque] ([Id])
);

