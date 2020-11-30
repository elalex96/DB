CREATE TABLE [dbo].[S_Notificacion_Respaldo] (
    [IdNotificacion]       BIGINT         NOT NULL,
    [Para]                 VARCHAR (1000) NULL,
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
    [EN_MsjEnviado]        BIT            NULL
);

