CREATE TABLE [dbo].[PR_PuntoEntregaDiario] (
    [PuntoEntregaID] INT             NOT NULL,
    [Fecha]          DATE            NOT NULL,
    [Presion]        DECIMAL (12, 4) NULL,
    [Temperatura]    DECIMAL (12, 4) NULL,
    [Eventos]        VARCHAR (3000)  NULL,
    [Dato]           VARCHAR (250)   NULL,
    [Nominal]        VARCHAR (500)   NULL,
    [Instantaneo]    VARCHAR (250)   NULL,
    [CreadoPor]      INT             NULL,
    [CreadoEl]       DATETIME        NULL,
    [ModificadoPor]  INT             NULL,
    [ModificadoEl]   DATETIME        NULL,
    CONSTRAINT [PK_PR_PuntoEntregaDiario] PRIMARY KEY CLUSTERED ([PuntoEntregaID] ASC, [Fecha] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PR_PuntoEntregaDiario_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_PR_PuntoEntregaDiario_AP_Usuario2] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_PR_PuntoEntregaDiario_CO_PuntosdeEntrega] FOREIGN KEY ([PuntoEntregaID]) REFERENCES [dbo].[CO_PuntosdeEntrega] ([PuntoEntregaID])
);

