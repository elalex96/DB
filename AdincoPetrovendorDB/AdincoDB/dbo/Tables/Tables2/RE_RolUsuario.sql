CREATE TABLE [dbo].[RE_RolUsuario] (
    [UsuarioId] INT           NOT NULL,
    [Rol]       VARCHAR (150) NULL,
    CONSTRAINT [PK_RE_RolUsuario] PRIMARY KEY CLUSTERED ([UsuarioId] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

