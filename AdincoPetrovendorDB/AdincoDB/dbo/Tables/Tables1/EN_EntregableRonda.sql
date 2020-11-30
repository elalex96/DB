CREATE TABLE [dbo].[EN_EntregableRonda] (
    [idEntregableRonda] INT IDENTITY (10000, 1) NOT NULL,
    [idEntregable]      INT NULL,
    [idRonda]           INT NULL,
    CONSTRAINT [PK__EN_Entre__E855B310CF5B1D15] PRIMARY KEY CLUSTERED ([idEntregableRonda] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK__EN_Entreg__idRon__5FAB783A] FOREIGN KEY ([idEntregable]) REFERENCES [dbo].[EN_Entregable] ([IdEntregable]),
    CONSTRAINT [FK__EN_Entreg__idRon__609F9C73] FOREIGN KEY ([idRonda]) REFERENCES [dbo].[EN_Rondas] ([idRonda])
);

