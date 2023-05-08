CREATE TABLE [dbo].[EN_DocumentosSASISOPA_Relacion] (
    [Id]                INT            IDENTITY (1, 1) NOT NULL,
    [IdBitacoraReporte] INT            NOT NULL,
    [IdDocumento]       INT            NOT NULL,
    [NombreDocumento]   VARCHAR (1000) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    FOREIGN KEY ([IdBitacoraReporte]) REFERENCES [dbo].[EN_Documentos_BitacoraReporteSASISOPA] ([Id]),
    FOREIGN KEY ([IdDocumento]) REFERENCES [dbo].[AWS_Documentos] ([AWSDocumentoId])
);

