CREATE TABLE [dbo].[ComprobantesAWSDocumentos] (
    [IdComprobanteAWSDocumento] INT      NOT NULL,
    [IdComprobante]             INT      NULL,
    [AWSDocumentoId]            INT      NULL,
    [FechaPago]                 DATE     NULL,
    [CreadoPor]                 INT      NULL,
    [CreadoEl]                  DATETIME NULL,
    CONSTRAINT [PK_ComprobantesAWSDocumentos] PRIMARY KEY CLUSTERED ([IdComprobanteAWSDocumento] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ComprobantesAWSDocumentos_AWS_Documentos] FOREIGN KEY ([AWSDocumentoId]) REFERENCES [dbo].[AWS_Documentos] ([AWSDocumentoId])
);

