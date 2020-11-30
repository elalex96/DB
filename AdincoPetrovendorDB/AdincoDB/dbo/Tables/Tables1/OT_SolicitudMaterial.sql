CREATE TABLE [dbo].[OT_SolicitudMaterial] (
    [IdOTSolicitudMaterial] INT             NOT NULL,
    [IdOTSolicitud]         INT             NOT NULL,
    [IdSCMaterial]          INT             NULL,
    [Cantidad]              DECIMAL (14, 5) NULL,
    [CreadoPor]             INT             NOT NULL,
    [CreadoEl]              DATETIME        NOT NULL,
    [ModificadoPor]         INT             NULL,
    [ModificadoEl]          DATETIME        NULL,
    [IdServicio]            INT             NULL,
    [FechaProgramaInicio]   DATETIME        NULL,
    [FechaProgramaFin]      DATETIME        NULL,
    [Comentarios]           VARCHAR (300)   NULL,
    CONSTRAINT [PK_OT_Material] PRIMARY KEY CLUSTERED ([IdOTSolicitudMaterial] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK__OT_Solici__IdSer__7BB1EEB4] FOREIGN KEY ([IdServicio]) REFERENCES [dbo].[CO_Servicio] ([IdServicio]),
    CONSTRAINT [FK_OT_SolicitudMaterial_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_OT_SolicitudMaterial_OT_Solicitud] FOREIGN KEY ([IdOTSolicitud]) REFERENCES [dbo].[OT_Solicitud] ([IdOTSolicitud]),
    CONSTRAINT [FK_OT_SolicitudMaterial_SC_Materiales] FOREIGN KEY ([IdSCMaterial]) REFERENCES [dbo].[SC_Materiales] ([IdSCMaterial])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_OT_SolicitudMaterial]
    ON [dbo].[OT_SolicitudMaterial]([IdOTSolicitud] ASC, [IdSCMaterial] ASC) WITH (STATISTICS_NORECOMPUTE = ON);

