CREATE TABLE [dbo].[AP_SeriesTipoCambio] (
    [Id]           INT           IDENTITY (1, 1) NOT NULL,
    [IdMoneda]     INT           NULL,
    [Pediodicidad] VARCHAR (150) NULL,
    [SerieBanxico] VARCHAR (150) NULL,
    [Tipo]         VARCHAR (150) NULL,
    [Descripcion]  VARCHAR (300) NULL,
    [CreadoPor]    INT           NULL,
    [CreadoEl]     DATETIME      NULL,
    CONSTRAINT [PK_SeriesTipoCambio] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [AP_SeriesTipoCambioCreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [AP_SeriesTipoCambioPV_TipoMoneda] FOREIGN KEY ([IdMoneda]) REFERENCES [dbo].[PV_TipoMoneda] ([IdMoneda])
);

