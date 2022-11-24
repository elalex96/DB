CREATE TABLE [dbo].[AWS_DocumentosRelacion] (
    [AWSDocumentoPadreId] INT      NOT NULL,
    [AWSDocumentoHijoId]  INT      NOT NULL,
    [CreadoEl]            DATETIME NOT NULL,
    [CreadoPor]           INT      NOT NULL,
    [ModificadoEl]        DATETIME NULL,
    [ModificadoPor]       INT      NULL,
    CONSTRAINT [PK_AWS_DocumentosRelacion] PRIMARY KEY CLUSTERED ([AWSDocumentoPadreId] ASC, [AWSDocumentoHijoId] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AWS_DocumentosRelacion_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_AWS_DocumentosRelacion_AP_Usuario1] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

