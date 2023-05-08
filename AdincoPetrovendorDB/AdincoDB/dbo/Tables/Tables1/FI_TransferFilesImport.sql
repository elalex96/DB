CREATE TABLE [dbo].[FI_TransferFilesImport] (
    [Id]             INT           NOT NULL,
    [IdImportacion]  INT           NOT NULL,
    [IdContratista]  INT           NOT NULL,
    [FileName]       VARCHAR (300) NOT NULL,
    [AWSDocumentoId] INT           NULL,
    [Procesado]      BIT           NOT NULL,
    [TieneError]     BIT           NOT NULL,
    [Error]          VARCHAR (50)  NULL,
    [CreadoEl]       DATETIME      NOT NULL,
    [CreadoPor]      INT           NOT NULL,
    CONSTRAINT [PK_FI_TransferFilesImport] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_FI_TransferFilesImport_AWS_Documentos] FOREIGN KEY ([AWSDocumentoId]) REFERENCES [dbo].[AWS_Documentos] ([AWSDocumentoId]),
    CONSTRAINT [FK_FI_TransferFilesImport_CO_Contratista] FOREIGN KEY ([IdContratista]) REFERENCES [dbo].[CO_Contratista] ([IdContratista])
);

