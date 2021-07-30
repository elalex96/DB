CREATE TABLE [dbo].[FI_PDFComplemento] (
    [IdPDFComplemento]     INT            IDENTITY (1, 1) NOT NULL,
    [IdFacturaComplemento] INT            NULL,
    [NombreDoc]            NVARCHAR (100) NULL,
    [Mime]                 NVARCHAR (50)  NULL,
    [Identificador]        NVARCHAR (100) NULL,
    [Carpeta]              NVARCHAR (100) NULL,
    [Activo]               BIT            NULL,
    [SubidoPor]            INT            NULL,
    [SubidoEl]             DATETIME       NULL,
    [Bucket] VARCHAR(MAX) NULL, 
    CONSTRAINT [PK_FI_PDFComplemento] PRIMARY KEY CLUSTERED ([IdPDFComplemento] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_FI_PDFComplemento_FI_Factura1] FOREIGN KEY ([IdFacturaComplemento]) REFERENCES [dbo].[FI_Factura] ([IdFactura]),
    CONSTRAINT [FK_FI_PDFComplemento_S_Usuario1] FOREIGN KEY ([SubidoPor]) REFERENCES [dbo].[S_Usuario] ([IdUsuario])
);

