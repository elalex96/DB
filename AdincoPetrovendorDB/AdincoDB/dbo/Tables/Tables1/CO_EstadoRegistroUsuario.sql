CREATE TABLE [dbo].[CO_EstadoRegistroUsuario] (
    [IdEstadoRegistroUsuario] INT      IDENTITY (10000, 1) NOT NULL,
    [IdClvEstado]             INT      NULL,
    [IdUsuario]               INT      NULL,
    [CreadoPor]               INT      NULL,
    [CreadoEn]                DATETIME NULL,
    [ModificadoPor]           INT      NULL,
    [ModificadoEn]            DATETIME NULL,
    CONSTRAINT [PK_CO_EstadoRegistroUsuario] PRIMARY KEY CLUSTERED ([IdEstadoRegistroUsuario] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_EstadoRegistroUsuario_AP_Usuario] FOREIGN KEY ([IdUsuario]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_CO_EstadoRegistroUsuario_AP_UsuarioCreado] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_CO_EstadoRegistroUsuario_AP_UsuarioModificado] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

