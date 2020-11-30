CREATE TABLE [dbo].[S_Documento] (
    [IdDocumento]               INT            IDENTITY (1, 1) NOT NULL,
    [IdTipoDocumento]           INT            NULL,
    [IdUsuario]                 INT            NULL,
    [IdTipoValidacionDocumento] INT            NULL,
    [IdProveedor]               INT            NULL,
    [Activo]                    BIT            NULL,
    [Documento]                 NVARCHAR (MAX) NOT NULL,
    [CreadoPor]                 INT            NULL,
    [CreadoEl]                  DATETIME       NULL,
    [ModificadoPor]             INT            NULL,
    [ModificadoEl]              DATETIME       NULL,
    [Descripcion]               NVARCHAR (MAX) NULL,
    [IdDocumentoS3]             INT            NULL,
    CONSTRAINT [PK_S_Documento] PRIMARY KEY CLUSTERED ([IdDocumento] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK__S_Documen__IdPro__57A801BA] FOREIGN KEY ([IdProveedor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor]),
    CONSTRAINT [FK__S_Documen__IdTip__55BFB948] FOREIGN KEY ([IdTipoDocumento]) REFERENCES [dbo].[S_TipoDocumento] ([IdTipoDocumento]),
    CONSTRAINT [FK__S_Documen__IdTip__589C25F3] FOREIGN KEY ([IdTipoValidacionDocumento]) REFERENCES [dbo].[S_TipoValidacionDoc] ([IdTipoValidacionDoc]),
    CONSTRAINT [FK__S_Documen__IdUsu__56B3DD81] FOREIGN KEY ([IdUsuario]) REFERENCES [dbo].[S_Usuario] ([IdUsuario])
);

