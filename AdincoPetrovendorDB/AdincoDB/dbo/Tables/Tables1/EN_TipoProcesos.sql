CREATE TABLE [dbo].[EN_TipoProcesos] (
    [idTipoProceso]     INT           IDENTITY (10000, 1) NOT NULL,
    [NombreTipoProceso] NVARCHAR (50) NULL,
    [CreadoPor]         INT           NULL,
    [CreadoEn]          DATETIME      NULL,
    [ModificadoPor]     INT           NULL,
    [ModificadoEn]      DATETIME      NULL,
    [Activo]            BIT           NULL,
    CONSTRAINT [PK_EN_TipoProcesos] PRIMARY KEY CLUSTERED ([idTipoProceso] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_EN_TipoProcesos_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_EN_TipoProcesos_AP_Usuario2] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

