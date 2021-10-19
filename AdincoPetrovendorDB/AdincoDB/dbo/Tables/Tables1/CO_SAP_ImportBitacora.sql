CREATE TABLE [dbo].[CO_SAP_ImportBitacora] (
    [Id]             INT      NOT NULL,
    [IdContrato]     INT      NOT NULL,
    [Inicio]         DATETIME NOT NULL,
    [Fin]            DATETIME NULL,
    [TieneError]     BIT      NOT NULL,
    [IdNotificacion] BIGINT   NULL,
    [CreadoEl]       DATETIME NOT NULL,
    [CreadoPor]      INT      NOT NULL,
    [NotificacionEnviada] BIT NULL, 
    CONSTRAINT [PK_CO_SAP_ImportBitacora] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_SAP_ImportBitacora_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_CO_SAP_ImportBitacora_S_Notificacion] FOREIGN KEY ([IdNotificacion]) REFERENCES [dbo].[S_Notificacion] ([IdNotificacion])
);

