CREATE TABLE [dbo].[S_DocumentoPlantillaOperadora] (
    [IdDocumentoPlantilla]       INT             IDENTITY (1, 1) NOT NULL,
    [NombreDocumentoObligatorio] NVARCHAR (1000) NULL,
    [DescripcionDocumento]       NVARCHAR (MAX)  NULL,
    [Obligatorio]                BIT             NULL,
    [IdDocumentoS3]              INT             NULL,
    [IdProveedor]                INT             NULL,
    [CreadoPor]                  INT             NULL,
    [CreadoEl]                   DATETIME        NULL,
    [Activo]                     BIT             NULL,
    [EliminadoPor]               INT             NULL,
    [EliminadoEl]                DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([IdDocumentoPlantilla] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK__S_DocumentoPlantillaOperadora__S_Documento_S3] FOREIGN KEY ([IdDocumentoS3]) REFERENCES [dbo].[S_Documento_S3] ([IdDocumento]),
    CONSTRAINT [FK__S_DocumentoPlantillaOperadora__S_Proveedor] FOREIGN KEY ([IdProveedor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor]),
    CONSTRAINT [FK__S_DocumentoPlantillaOperadora__S_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[S_Usuario] ([IdUsuario])
);

