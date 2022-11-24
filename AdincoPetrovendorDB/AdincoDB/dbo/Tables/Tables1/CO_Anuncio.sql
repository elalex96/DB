CREATE TABLE [dbo].[CO_Anuncio] (
    [IdAnuncio]     INT           IDENTITY (10000, 1) NOT NULL,
    [IdContrato]    INT           NULL,
    [Anuncio]       VARCHAR (MAX) NULL,
    [URL]           VARCHAR (MAX) NULL,
    [FechaInicio]   DATE          NULL,
    [FechaVigencia] DATE          NULL,
    [DiasNovedad]   INT           NULL,
    [CreadoPor]     INT           NULL,
    [CreadoEl]      DATETIME      NULL,
    [ModificadoPor] INT           NULL,
    [ModificadoEl]  DATETIME      NULL,
    CONSTRAINT [PK_Notificacion] PRIMARY KEY CLUSTERED ([IdAnuncio] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Contrato_Notificacion] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_CreadoPor_Notificacion] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_ModificadoPor_Notificacion] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

