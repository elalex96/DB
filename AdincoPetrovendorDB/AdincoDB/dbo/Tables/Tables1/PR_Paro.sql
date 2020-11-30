CREATE TABLE [dbo].[PR_Paro] (
    [Id]                 INT             IDENTITY (1, 1) NOT NULL,
    [Pozo]               INT             NOT NULL,
    [Inicio]             DATETIME        NOT NULL,
    [Fin]                DATETIME        NOT NULL,
    [Duracion]           DECIMAL (24, 8) NULL,
    [Programado]         TINYINT         NOT NULL,
    [Motivo]             INT             NOT NULL,
    [Estatus]            TINYINT         NOT NULL,
    [Origen]             INT             NOT NULL,
    [ProduccionDiferida] DECIMAL (24, 8) NOT NULL,
    [Comentarios]        NVARCHAR (2000) NULL,
    [Finalizado]         INT             NOT NULL,
    [Modificado]         DATETIME        NULL,
    [ModificadoPor]      VARCHAR (200)   NULL,
    [ModificadoServer]   DATETIME        NULL,
    CONSTRAINT [PK_PR_Paro] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Paro_Pozo] FOREIGN KEY ([Pozo]) REFERENCES [dbo].[PR_Pozo] ([Id]),
    CONSTRAINT [FK_Paro_RubroParo] FOREIGN KEY ([Motivo]) REFERENCES [dbo].[PR_RubroParo] ([Id])
);

