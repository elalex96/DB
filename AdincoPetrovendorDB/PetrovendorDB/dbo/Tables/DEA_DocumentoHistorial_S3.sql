CREATE TABLE [dbo].[DEA_DocumentoHistorial_S3] (
    [IdDocumentoHistorial_S3]   INT            IDENTITY (1, 1) NOT NULL,
    [IdDocumento]               INT            NULL,
    [IdTipoDocumento]           INT            NULL,
    [IdUsuario]                 INT            NULL,
    [IdTipoValidacionDocumento] INT            NULL,
    [IdProveedor]               INT            NULL,
    [Activo]                    BIT            NULL,
    [Documento]                 NVARCHAR (MAX) NULL,
    [CreadoPor]                 INT            NULL,
    [CreadoEl]                  DATETIME       NULL,
    [ModificadoPor]             INT            NULL,
    [ModificadoEl]              DATETIME       NULL,
    [Descripcion]               NVARCHAR (MAX) NULL,
    [Carpeta]                   NVARCHAR (MAX) NULL,
    [Identificador]             NVARCHAR (MAX) NULL,
    [Mime]                      NVARCHAR (MAX) NULL,
    [Extension]                 NVARCHAR (MAX) NULL,
    [NombreDocumento]           NVARCHAR (MAX) NULL,
    [Duplicado]                 NVARCHAR (40)  NULL,
    [SizeDocumento]             FLOAT (53)     NULL,
    [IdDocumentoTabla]          INT            NULL
);

