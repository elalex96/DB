CREATE TABLE [dbo].[CO_PresupuestoDetalle] (
    [IdPresupuestoDetalle]       INT      IDENTITY (10000, 1) NOT NULL,
    [IdPresupuesto]              INT      NULL,
    [IdProgramaActividadDetalle] INT      NULL,
    [CreadoPor]                  INT      NULL,
    [CreadoEl]                   DATETIME NULL,
    [ModificadoPor]              INT      NULL,
    [ModificadoEl]               DATETIME NULL,
    [Activo]                     BIT      NULL,
    CONSTRAINT [PK_CO_PresupuestoDetalle] PRIMARY KEY CLUSTERED ([IdPresupuestoDetalle] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_PresupuestoDetalle_AP_Usuario] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_CO_PresupuestoDetalle_CO_Presupuesto] FOREIGN KEY ([IdPresupuesto]) REFERENCES [dbo].[CO_Presupuesto] ([IdPresupuesto]),
    CONSTRAINT [FK_CO_PresupuestoDetalle_CO_ProgramaActividadDetalle] FOREIGN KEY ([IdProgramaActividadDetalle]) REFERENCES [dbo].[CO_ProgramaActividadDetalle] ([IdProgramaActividadDetalle])
);

