CREATE TABLE [dbo].[S_TipoDocumentoTipoPersona] (
    [IdDocumentoProveedor] INT IDENTITY (1, 1) NOT NULL,
    [IdTipoRegimen]        INT NULL,
    [IdTipoDocumento]      INT NULL,
    [Activo]               BIT NULL,
    CONSTRAINT [PK_S_DocumentoProveedor] PRIMARY KEY CLUSTERED ([IdDocumentoProveedor] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

