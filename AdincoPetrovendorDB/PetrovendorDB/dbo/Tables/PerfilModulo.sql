CREATE TABLE [dbo].[PerfilModulo] (
    [IdPerfilModulo]    INT      IDENTITY (1, 1) NOT NULL,
    [IdPerfil]          INT      NULL,
    [IdModulo]          INT      NULL,
    [Activo]            BIT      NULL,
    [CreadoPor]         INT      NULL,
    [CreadoEl]          DATETIME NULL,
    [ModificadoPor]     INT      NULL,
    [ModificadoEl]      DATETIME NULL,
    [IdFiltroProveedor] INT      NULL,
    [IsEliminado]       BIT      NULL,
    CONSTRAINT [PK_PerfilModulo] PRIMARY KEY CLUSTERED ([IdPerfilModulo] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PerfilModulo_Modulo] FOREIGN KEY ([IdModulo]) REFERENCES [dbo].[Modulo] ([IdModulo]),
    CONSTRAINT [FK_PerfilModulo_S_TipoUsuario] FOREIGN KEY ([IdPerfil]) REFERENCES [dbo].[S_TipoUsuario] ([IdTipoUsuario])
);


GO
CREATE NONCLUSTERED INDEX [PerfilModulo_Perfil_ActivoFiltro]
    ON [dbo].[PerfilModulo]([IdPerfil] ASC, [Activo] ASC, [IdFiltroProveedor] ASC) WITH (STATISTICS_NORECOMPUTE = ON);

