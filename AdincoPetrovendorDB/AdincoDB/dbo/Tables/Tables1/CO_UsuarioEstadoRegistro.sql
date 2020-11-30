CREATE TABLE [dbo].[CO_UsuarioEstadoRegistro] (
    [IdUsuarioEstadoRegistro] INT IDENTITY (1, 1) NOT NULL,
    [IdUsuario]               INT NULL,
    [IdEstadoRegistro]        INT NULL,
    [CreadoPor]               INT NULL,
    CONSTRAINT [PK_UsuarioEstadoRegistro] PRIMARY KEY CLUSTERED ([IdUsuarioEstadoRegistro] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_UsuarioEstadoRegistro_EstadoRegistro] FOREIGN KEY ([IdEstadoRegistro]) REFERENCES [dbo].[CO_EstadoRegistro] ([IdEstadoRegistro])
);

