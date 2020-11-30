CREATE TABLE [dbo].[S_UsuarioRol] (
    [S_RolUsuario] INT      IDENTITY (1, 1) NOT NULL,
    [IdUsuario]    INT      NOT NULL,
    [IdRol]        INT      NULL,
    [Activo]       BIT      NULL,
    [IdCreadoPor]  INT      NULL,
    [CreadoEl]     DATETIME NULL,
    [EditadoEl]    DATETIME NULL,
    [IdEditadoPor] INT      NULL,
    CONSTRAINT [PK_S_UsuarioRol] PRIMARY KEY CLUSTERED ([S_RolUsuario] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

