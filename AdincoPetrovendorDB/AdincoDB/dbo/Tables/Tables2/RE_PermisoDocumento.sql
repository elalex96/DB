CREATE TABLE [dbo].[RE_PermisoDocumento] (
    [UsuarioId]       INT NOT NULL,
    [TipoDocumentoId] INT NOT NULL,
    [PuedeVer]        BIT NULL,
    [PuedeEditar]     BIT NULL,
    CONSTRAINT [PK_RE_PermisoDocumento] PRIMARY KEY CLUSTERED ([UsuarioId] ASC, [TipoDocumentoId] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

