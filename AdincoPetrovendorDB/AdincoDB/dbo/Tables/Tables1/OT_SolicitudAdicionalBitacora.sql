CREATE TABLE [dbo].[OT_SolicitudAdicionalBitacora] (
    [Id]                     INT           IDENTITY (1, 1) NOT NULL,
    [IdOTSolicitudAdicional] INT           NOT NULL,
    [IdOTEstatusAdicional]   TINYINT       NULL,
    [Descripcion]            VARCHAR (300) NULL,
    [CreadoEl]               DATETIME      NOT NULL,
    [CreadoPor]              INT           NOT NULL,
    CONSTRAINT [PK_OT_SolicitudAdicionalBitacora] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_OT_SolicitudAdicionalBitacora_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_OT_SolicitudAdicionalBitacora_OT_EstatusAdicional] FOREIGN KEY ([IdOTEstatusAdicional]) REFERENCES [dbo].[OT_EstatusAdicional] ([IdEstatusAdicional]),
    CONSTRAINT [FK_OT_SolicitudAdicionalBitacora_OT_SolicitudAdicional] FOREIGN KEY ([IdOTSolicitudAdicional]) REFERENCES [dbo].[OT_SolicitudAdicional] ([IdOTSolicitudAdicional])
);

