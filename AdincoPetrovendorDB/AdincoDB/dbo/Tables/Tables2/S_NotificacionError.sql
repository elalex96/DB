CREATE TABLE [dbo].[S_NotificacionError] (
    [IdNotificacionError] INT           NOT NULL,
    [IdNotificacion]      BIGINT        NOT NULL,
    [Error]               VARCHAR (350) NOT NULL,
    [FechaRegistro]       DATETIME      NOT NULL,
    CONSTRAINT [PK_S_NotificacionError] PRIMARY KEY CLUSTERED ([IdNotificacionError] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_S_NotificacionError_S_Notificacion] FOREIGN KEY ([IdNotificacion]) REFERENCES [dbo].[S_Notificacion] ([IdNotificacion])
);

