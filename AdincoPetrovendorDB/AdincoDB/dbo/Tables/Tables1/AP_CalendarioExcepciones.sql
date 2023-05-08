CREATE TABLE [dbo].[AP_CalendarioExcepciones] (
    [IdFecha]       DATE           NOT NULL,
    [IdRegulador]   INT            NOT NULL,
    [Descripcion]   VARCHAR (2000) NULL,
    [DiaDeSemana]   TINYINT        NULL,
    [CreadoPor]     INT            NULL,
    [CreadoEn]      DATETIME       NULL,
    [ModificadoPor] INT            NULL,
    [ModificadoEn]  DATETIME       NULL,
    [Activo]        BIT            NULL,
    CONSTRAINT [PK_AP_CalendarioExc] PRIMARY KEY CLUSTERED ([IdFecha] ASC, [IdRegulador] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AP_CalendarioExc_Regulador] FOREIGN KEY ([IdRegulador]) REFERENCES [dbo].[CO_Regulador] ([IdRegulador]),
    CONSTRAINT [FK_CreadoPor_AP_CalendarioExc] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_ModificadoPor_AP_CalendarioExc] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

