CREATE TABLE [dbo].[FI_ArchivoXml] (
    [IdArchivoXml]  INT            IDENTITY (10000, 1) NOT NULL,
    [ArchivoXml]    IMAGE          NULL,
    [HashSHA256]    NVARCHAR (MAX) NULL,
    [IdFactura]     INT            NULL,
    [IdContrato]    INT            NULL,
    [CreadoPor]     INT            NULL,
    [CreadoEl]      DATETIME       NULL,
    [ModificadoPor] INT            NULL,
    [ModificadoEl]  DATETIME       NULL,
    [Activo]        BIT            NULL,
    PRIMARY KEY CLUSTERED ([IdArchivoXml] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    FOREIGN KEY ([IdFactura]) REFERENCES [dbo].[FI_Factura] ([IdFactura]),
    CONSTRAINT [FK__FI_Archiv__IdFac__71B5E533] FOREIGN KEY ([IdFactura]) REFERENCES [dbo].[FI_Factura] ([IdFactura])
);

