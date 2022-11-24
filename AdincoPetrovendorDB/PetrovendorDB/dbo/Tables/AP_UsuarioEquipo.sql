CREATE TABLE [dbo].[AP_UsuarioEquipo] (
    [IdUsuarioEqp]  INT      IDENTITY (1, 1) NOT NULL,
    [IdUsuario]     INT      NULL,
    [IdEquipo]      INT      NULL,
    [FechaRegistro] DATETIME NULL,
    [Activo]        BIT      NULL,
    CONSTRAINT [PK_AP_UsuarioEquipo] PRIMARY KEY CLUSTERED ([IdUsuarioEqp] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AP_UsuarioEquipo_AP_Equipo] FOREIGN KEY ([IdEquipo]) REFERENCES [dbo].[AP_Equipo] ([IdEquipo]),
    CONSTRAINT [FK_AP_UsuarioEquipo_Usuarios] FOREIGN KEY ([IdUsuario]) REFERENCES [dbo].[S_Usuario] ([IdUsuario])
);

