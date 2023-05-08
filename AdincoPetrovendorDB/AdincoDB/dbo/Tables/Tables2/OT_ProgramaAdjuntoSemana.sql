CREATE TABLE [dbo].[OT_ProgramaAdjuntoSemana] (
    [ID]                    INT           NOT NULL,
    [IdOTSolicitudMaterial] INT           NOT NULL,
    [FechaInicioSemana]     DATETIME      NOT NULL,
    [FechaFinSemana]        DATETIME      NOT NULL,
    [CreadoPor]             VARCHAR (150) NOT NULL,
    [CreadoEl]              DATETIME      NOT NULL,
    [AWSDocumentoId]        INT           NULL,
    CONSTRAINT [PK_OT_ProgramaAdjuntoSemana] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_OT_ProgramaAdjuntoSemana_AWS_Documentos] FOREIGN KEY ([AWSDocumentoId]) REFERENCES [dbo].[AWS_Documentos] ([AWSDocumentoId]),
    CONSTRAINT [FK_OT_ProgramaAdjuntoSemana_OT_SolicitudMaterial] FOREIGN KEY ([IdOTSolicitudMaterial]) REFERENCES [dbo].[OT_SolicitudMaterial] ([IdOTSolicitudMaterial])
);

