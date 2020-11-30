CREATE TABLE [dbo].[MM_AceptacionDocumento_Proveedor] (
    [IdAceptacionDocumento]    INT            IDENTITY (1, 1) NOT NULL,
    [IdTipoDocumentoOperadora] INT            NULL,
    [IdDocumentoS3Proveedor]   INT            NULL,
    [IdProveedor]              INT            NULL,
    [IdOperadora]              INT            NULL,
    [IdEstatus]                INT            NULL,
    [Activo]                   INT            NULL,
    [CreadoEl]                 DATETIME       NULL,
    [CreadoPor]                INT            NULL,
    [Comentario]               NVARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([IdAceptacionDocumento] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK__MM_AceptacionDocumento_Proveedor__S_Documento_S3] FOREIGN KEY ([IdDocumentoS3Proveedor]) REFERENCES [dbo].[S_Documento_S3] ([IdDocumento]),
    CONSTRAINT [FK__MM_AceptacionDocumento_Proveedor__S_Operadora] FOREIGN KEY ([IdOperadora]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor]),
    CONSTRAINT [FK__MM_AceptacionDocumento_Proveedor__S_Proveedor] FOREIGN KEY ([IdProveedor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor]),
    CONSTRAINT [FK__MM_AceptacionDocumento_Proveedor__S_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[S_Usuario] ([IdUsuario]),
    CONSTRAINT [FK__MM_AceptacionDocumento_Proveedor__TA_Estatus] FOREIGN KEY ([IdEstatus]) REFERENCES [dbo].[TA_Estatus] ([IdEstatus])
);

