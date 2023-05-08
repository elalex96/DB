CREATE TABLE [dbo].[OT_SolicitudAdicionalMaterial] (
    [Id]                     INT        NOT NULL,
    [IdOTSolicitudAdicional] INT        NOT NULL,
    [IdSCMaterial]           INT        NOT NULL,
    [Cantidad]               FLOAT (53) NOT NULL,
    [FechaProgramaInicio]    DATETIME   NOT NULL,
    [FechaProgramaFin]       DATETIME   NOT NULL,
    [CreadoEl]               DATETIME   NOT NULL,
    [CreadoPor]              INT        NOT NULL,
    [ModificadoEl]           DATETIME   NULL,
    [ModificadoPor]          INT        NULL,
    CONSTRAINT [PK_OT_SolicitudAdicionalMaterial_1] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_OT_SolicitudAdicionalMaterial_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_OT_SolicitudAdicionalMaterial_AP_Usuario1] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_OT_SolicitudAdicionalMaterial_OT_SolicitudAdicional] FOREIGN KEY ([IdOTSolicitudAdicional]) REFERENCES [dbo].[OT_SolicitudAdicional] ([IdOTSolicitudAdicional]),
    CONSTRAINT [FK_OT_SolicitudAdicionalMaterial_SC_Materiales] FOREIGN KEY ([IdSCMaterial]) REFERENCES [dbo].[SC_Materiales] ([IdSCMaterial])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_OT_SolicitudAdicionalMaterial]
    ON [dbo].[OT_SolicitudAdicionalMaterial]([IdOTSolicitudAdicional] ASC, [IdSCMaterial] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);

