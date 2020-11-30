CREATE TABLE [dbo].[PR_Bombeo] (
    [Id]                        INT             IDENTITY (1, 1) NOT NULL,
    [Fecha]                     DATETIME        NOT NULL,
    [EstacionOrigen]            INT             NOT NULL,
    [TanqueOrigen]              INT             NOT NULL,
    [EstacionDestino]           INT             NOT NULL,
    [Inicio]                    DATETIME        NOT NULL,
    [MedidaInicial]             DECIMAL (24, 8) NOT NULL,
    [Fin]                       DATETIME        NOT NULL,
    [MedidaFinal]               DECIMAL (24, 8) NOT NULL,
    [Duracion]                  DECIMAL (24, 8) NULL,
    [VolumenBombeado]           DECIMAL (24, 8) NOT NULL,
    [PresionInicial]            DECIMAL (24, 8) NOT NULL,
    [PresionPromedio]           DECIMAL (24, 8) NOT NULL,
    [Modificado]                DATETIME        NULL,
    [ModificadoPor]             VARCHAR (200)   NULL,
    [ModificadoServer]          DATETIME        NULL,
    [VolumenBombeadoCondensado] DECIMAL (24, 8) NULL,
    CONSTRAINT [PK_PR_PR_Bombeo] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Bombeo_Estacion] FOREIGN KEY ([EstacionOrigen]) REFERENCES [dbo].[PR_Estacion] ([Id]),
    CONSTRAINT [FK_Bombeo_Estacion1] FOREIGN KEY ([EstacionDestino]) REFERENCES [dbo].[PR_Estacion] ([Id]),
    CONSTRAINT [FK_Bombeo_Tanque] FOREIGN KEY ([TanqueOrigen]) REFERENCES [dbo].[PR_Tanque] ([Id])
);

