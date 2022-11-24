CREATE TABLE [dbo].[FacturasAWSDocumentos] (
    [IdFacturaAWSDocumento] INT      NOT NULL,
    [IdFactura]             INT      NULL,
    [AWSDocumentoId]        INT      NULL,
    [FechaPago]             DATE     NULL,
    [CreadoPor]             INT      NULL,
    [CreadoEl]              DATETIME NULL,
    CONSTRAINT [PK_FacturasAWSDocumentos] PRIMARY KEY CLUSTERED ([IdFacturaAWSDocumento] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_FacturasAWSDocumentos_AWS_Documentos] FOREIGN KEY ([AWSDocumentoId]) REFERENCES [dbo].[AWS_Documentos] ([AWSDocumentoId]),
    CONSTRAINT [FK_FacturasAWSDocumentos_FI_Factura] FOREIGN KEY ([IdFactura]) REFERENCES [dbo].[FI_Factura] ([IdFactura])
);

