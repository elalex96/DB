CREATE TABLE [dbo].[OT_SolicitudPrograma] (
    [IdOTSolicitudPrograma] INT             NOT NULL,
    [IdOTSolicitudMaterial] INT             NOT NULL,
    [Anio]                  SMALLINT        NOT NULL,
    [Mes]                   TINYINT         NOT NULL,
    [Cantidad]              DECIMAL (14, 5) NULL,
    [CreadoPor]             INT             NOT NULL,
    [CreadoEl]              DATETIME        NOT NULL,
    [ModificadoPor]         INT             NULL,
    [ModificadoEl]          DATETIME        NULL,
    [IdEstatus]             BIT             NULL,
    CONSTRAINT [PK_OT_SolicitudPrograma] PRIMARY KEY CLUSTERED ([IdOTSolicitudPrograma] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_OT_SolicitudPrograma_OT_SolicitudMaterial] FOREIGN KEY ([IdOTSolicitudMaterial]) REFERENCES [dbo].[OT_SolicitudMaterial] ([IdOTSolicitudMaterial])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_OT_SolicitudPrograma]
    ON [dbo].[OT_SolicitudPrograma]([IdOTSolicitudMaterial] ASC, [Anio] ASC, [Mes] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);

