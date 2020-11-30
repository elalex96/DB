CREATE TABLE [dbo].[Relacion_TableroRolTipo] (
    [IdTableroTipoUsuarioRol] INT      IDENTITY (1, 1) NOT NULL,
    [IdProveedor]             INT      NULL,
    [IdTipoUsuario]           INT      NULL,
    [IdRol]                   INT      NULL,
    [IdTablero]               INT      NULL,
    [IdUsuario]               INT      NULL,
    [IdCreadoPor]             INT      NULL,
    [FechaRegistro]           DATETIME NULL,
    [Activo]                  BIT      NULL,
    [IdContrato]              INT      NULL,
    CONSTRAINT [PK_Relacion_TableroRolTipo] PRIMARY KEY CLUSTERED ([IdTableroTipoUsuarioRol] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

