CREATE TABLE [dbo].[S_Notificacion] (
    [IdNotificacion]       BIGINT         NOT NULL,
    [Para]                 VARCHAR (3000) NULL,
    [Asunto]               VARCHAR (500)  NULL,
    [Mensaje]              TEXT           NOT NULL,
    [FechaProgramadaEnvio] DATETIME       NOT NULL,
    [Enviada]              BIT            NOT NULL,
    [FechaEnvio]           DATETIME       NULL,
    [CreadoPor]            INT            NOT NULL,
    [CreadoEl]             DATETIME       NOT NULL,
    [ModificadoPor]        INT            NULL,
    [ModificadoEl]         DATETIME       NULL,
    [De]                   VARCHAR (100)  NULL,
    [EN_MsjEnviado]        BIT            NULL,
    CONSTRAINT [PK_S_Notificacion] PRIMARY KEY CLUSTERED ([IdNotificacion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_S_Notificacion_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_S_Notificacion_AP_Usuario1] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);


GO
CREATE NONCLUSTERED INDEX [S_Notificacion_Enviada]
    ON [dbo].[S_Notificacion]([Enviada] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);

