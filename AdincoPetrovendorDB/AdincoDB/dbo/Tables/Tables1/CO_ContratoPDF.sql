CREATE TABLE [dbo].[CO_ContratoPDF] (
    [IdContratoPDF]  INT      IDENTITY (1, 1) NOT NULL,
    [IdContrato]     INT      NULL,
    [AWSDocumentoId] INT      NULL,
    [CreadoPor]      INT      NULL,
    [CreadoEl]       DATETIME NULL,
    [ModificadoPor]  INT      NULL,
    [ModificadoEl]   DATETIME NULL,
    [Activo]         BIT      NULL,
    CONSTRAINT [PK_ContratoPDF] PRIMARY KEY CLUSTERED ([IdContratoPDF] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AWSPDF] FOREIGN KEY ([AWSDocumentoId]) REFERENCES [dbo].[AWS_Documentos] ([AWSDocumentoId]),
    CONSTRAINT [FK_ContratoPDF] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

