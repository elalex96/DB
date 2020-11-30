CREATE TABLE [dbo].[AdministracionPermisosUsuarios] (
    [IdPerfilModuloUsuario] INT      IDENTITY (1, 1) NOT NULL,
    [IdPerfil]              INT      NULL,
    [IdModulo]              INT      NULL,
    [Activo]                BIT      NULL,
    [CreadoPor]             INT      NULL,
    [CreadoEl]              DATETIME NULL,
    [ModificadoPor]         INT      NULL,
    [ModificadoEl]          DATETIME NULL,
    [IsEliminado]           BIT      NULL,
    [IdFiltroUsuario]       INT      NULL,
    [IdProveedor]           INT      NULL,
    CONSTRAINT [PK_AdministracionPermisosUsuarios] PRIMARY KEY CLUSTERED ([IdPerfilModuloUsuario] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

