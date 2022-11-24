CREATE TABLE [dbo].[EN_GruposUsuarios] (
    [IdGruposUsuarios] INT      IDENTITY (10000, 1) NOT NULL,
    [IdGrupo]          INT      NOT NULL,
    [IdUsuario]        INT      NOT NULL,
    [IdContrato]       INT      NULL,
    [CreadoPor]        INT      NULL,
    [CreadoEn]         DATETIME NULL,
    [ModificadoPor]    INT      NULL,
    [ModificadoEn]     DATETIME NULL,
    [Activo]           BIT      NULL,
    CONSTRAINT [PK_GruposUsuarios] PRIMARY KEY CLUSTERED ([IdGrupo] ASC, [IdUsuario] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Contratos] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_CreadoPorGruposUsuarios] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_Grupos] FOREIGN KEY ([IdGrupo]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_ModificadoPorGruposUsuarios] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_Usuarios] FOREIGN KEY ([IdUsuario]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

