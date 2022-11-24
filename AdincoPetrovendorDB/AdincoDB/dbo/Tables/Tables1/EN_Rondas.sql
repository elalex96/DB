CREATE TABLE [dbo].[EN_Rondas] (
    [idRonda]   INT          IDENTITY (10000, 1) NOT NULL,
    [Ronda]     VARCHAR (20) NULL,
    [CoIdRonda] INT          NULL,
    CONSTRAINT [PK__EN_Ronda__5A93229AF35946B1] PRIMARY KEY CLUSTERED ([idRonda] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CoIdRonda] FOREIGN KEY ([CoIdRonda]) REFERENCES [dbo].[CO_Rondas] ([IdRonda])
);

