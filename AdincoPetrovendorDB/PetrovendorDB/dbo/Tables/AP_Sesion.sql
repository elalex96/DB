CREATE TABLE [dbo].[AP_Sesion] (
    [IdSesion]     INT      IDENTITY (1, 1) NOT NULL,
    [IdUsuario]    INT      NULL,
    [IdEquipo]     INT      NULL,
    [FechaInicio]  DATETIME NULL,
    [horaInicio]   DATETIME NULL,
    [FechaTermino] DATETIME NULL,
    [HoraTermino]  DATETIME NULL,
    [Activo]       BIT      NULL,
    CONSTRAINT [PK_AP_Sesion] PRIMARY KEY CLUSTERED ([IdSesion] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AP_Sesion_AP_Sesion] FOREIGN KEY ([IdSesion]) REFERENCES [dbo].[AP_Sesion] ([IdSesion]),
    CONSTRAINT [FK_AP_Sesion_AP_Sesion1] FOREIGN KEY ([IdSesion]) REFERENCES [dbo].[AP_Sesion] ([IdSesion]),
    CONSTRAINT [FK_Sesion_AP_Equipo] FOREIGN KEY ([IdEquipo]) REFERENCES [dbo].[AP_Equipo] ([IdEquipo])
);

