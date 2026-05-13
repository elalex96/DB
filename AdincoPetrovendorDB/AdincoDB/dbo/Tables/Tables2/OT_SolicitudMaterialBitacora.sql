CREATE TABLE [dbo].[OT_SolicitudMaterialBitacora] (
    [IdOTBitacoraId]          INT             NOT NULL,
    [IdOTSolicitudMaterial]   INT             NOT NULL,
    [Cantidad]                DECIMAL (14, 2) NOT NULL,
    [FechaProgramacionInicio] DATETIME        NOT NULL,
    [FechaProgramacionFin]    DATETIME        NOT NULL,
    [IdTipoUsuario]           INT             NOT NULL,
    [CreadoPor]               INT             NOT NULL,
    [CreadoEl]                DATETIME        NOT NULL,
    CONSTRAINT [PK_OT_SolicitudMaterialBitacora] PRIMARY KEY CLUSTERED ([IdOTBitacoraId] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_OT_SolicitudMaterialBitacora_OT_SolicitudMaterial] FOREIGN KEY ([IdOTSolicitudMaterial]) REFERENCES [dbo].[OT_SolicitudMaterial] ([IdOTSolicitudMaterial])
);

