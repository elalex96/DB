CREATE TABLE [dbo].[CO_ProgramaImplementaDepartamentoUsuario] (
    [IdProgramaImplementaDepartamento] SMALLINT NOT NULL,
    [IdUsuario]                        INT      NOT NULL,
    [CreadoEl]                         DATETIME NOT NULL,
    [CreadoPor]                        INT      NOT NULL,
    [Activo]                           BIT      NULL,
    CONSTRAINT [PK_CO_ProgramaImplementaDepartamentoUsuario] PRIMARY KEY CLUSTERED ([IdProgramaImplementaDepartamento] ASC, [IdUsuario] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_ProgramaImplementaDepartamentoUsuario_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

