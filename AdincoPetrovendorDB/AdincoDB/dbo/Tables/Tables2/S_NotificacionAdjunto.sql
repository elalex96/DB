CREATE TABLE [dbo].[S_NotificacionAdjunto] (
    [IdNotificacionAdjunto] BIGINT        NOT NULL,
    [IdNotificacion]        BIGINT        NOT NULL,
    [NombreArchivo]         VARCHAR (250) NOT NULL,
    [Adjunto]               IMAGE         NOT NULL,
    [CreadoPor]             INT           NOT NULL,
    [CreadoEl]              DATETIME      NOT NULL,
    CONSTRAINT [PK_S_NotificacionAdjunto] PRIMARY KEY CLUSTERED ([IdNotificacionAdjunto] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_S_NotificacionAdjunto_S_Notificacion] FOREIGN KEY ([IdNotificacion]) REFERENCES [dbo].[S_Notificacion] ([IdNotificacion])
);

