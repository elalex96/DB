CREATE TABLE [dbo].[EN_DocumentoFormatoFichaTecnica] (
    [IdFormatoFichaTecnica]     INT              IDENTITY (1, 1) NOT NULL,
    [idEntregable]              INT              NULL,
    [Bucket]                    VARCHAR (1000)   NULL,
    [Folder]                    VARCHAR (1000)   NULL,
    [UUIDAmazon]                UNIQUEIDENTIFIER NULL,
    [NombreArchivo]             VARCHAR (1000)   NULL,
    [Meta]                      VARCHAR (1000)   NULL,
    [idTipoFormatoFichaTecnica] INT              NULL,
    [CreadoPor]                 INT              NULL,
    [CreadoEl]                  DATETIME         NULL,
    [ModificadoPor]             INT              NULL,
    [ModificadoEl]              DATETIME         NULL,
    [Activo]                    BIT              NULL,
    CONSTRAINT [PK_EN_DocumentoFormatoFichaTecnica] PRIMARY KEY CLUSTERED ([IdFormatoFichaTecnica] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [CreadoPor_EN_DocumentoFormatoFichaTecnica] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [EN_entregable_EN_DocumentoFormatoFichaTecnica] FOREIGN KEY ([idEntregable]) REFERENCES [dbo].[EN_Entregable] ([IdEntregable]),
    CONSTRAINT [Modificado_EN_DocumentoFormatoFichaTecnica] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [Tipo_EN_DocumentoFormatoFichaTecnica] FOREIGN KEY ([idTipoFormatoFichaTecnica]) REFERENCES [dbo].[EN_TipoFormatoFichaTecnica] ([idTipoFormatoFichaTecnica])
);

