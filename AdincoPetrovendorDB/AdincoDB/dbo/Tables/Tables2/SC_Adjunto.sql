CREATE TABLE [dbo].[SC_Adjunto] (
    [IdAdjunto]      INT           NOT NULL,
    [IdSubcontrato]  INT           NOT NULL,
    [Descripcion]    VARCHAR (250) NOT NULL,
    [Adjunto]        IMAGE         NULL,
    [Extension]      VARCHAR (7)   NOT NULL,
    [CreadoPor]      INT           NOT NULL,
    [CreadoEl]       DATETIME      NOT NULL,
    [ModificadoPor]  INT           NULL,
    [ModificadoEl]   DATETIME      NULL,
    [AWSDocumentoId] INT           NULL,
    CONSTRAINT [PK_SC_Adjuntos] PRIMARY KEY CLUSTERED ([IdAdjunto] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    FOREIGN KEY ([AWSDocumentoId]) REFERENCES [dbo].[AWS_Documentos] ([AWSDocumentoId]),
    CONSTRAINT [FK_SC_Adjuntos_SC_SubContratos] FOREIGN KEY ([IdSubcontrato]) REFERENCES [dbo].[SC_SubContrato] ([IdSubContrato])
);

