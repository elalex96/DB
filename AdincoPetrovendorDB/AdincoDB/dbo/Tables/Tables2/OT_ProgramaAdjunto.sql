CREATE TABLE [dbo].[OT_ProgramaAdjunto] (
    [ID]             INT           NOT NULL,
    [IdOTSolicitud]  INT           NOT NULL,
    [CreadoPor]      VARCHAR (100) NOT NULL,
    [CreadoEl]       DATETIME      NOT NULL,
    [AWSDocumentoId] INT           NULL,
    CONSTRAINT [PK_OT_ProgramaAdjunto] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_OT_ProgramaAdjunto_AWSDocumentoId] FOREIGN KEY ([AWSDocumentoId]) REFERENCES [dbo].[AWS_Documentos] ([AWSDocumentoId]),
    CONSTRAINT [FK_OT_ProgramaAdjunto_OT_Solicitud] FOREIGN KEY ([IdOTSolicitud]) REFERENCES [dbo].[OT_Solicitud] ([IdOTSolicitud])
);

