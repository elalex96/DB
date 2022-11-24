CREATE TABLE [dbo].[RESPLADO_S_NotificacionError] (
    [IdNotificacionError] INT           NOT NULL,
    [IdNotificacion]      BIGINT        NOT NULL,
    [Error]               VARCHAR (350) NOT NULL,
    [FechaRegistro]       DATETIME      NOT NULL
);

