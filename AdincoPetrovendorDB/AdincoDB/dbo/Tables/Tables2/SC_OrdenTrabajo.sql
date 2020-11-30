CREATE TABLE [dbo].[SC_OrdenTrabajo] (
    [IdOrdenTrabajo]        INT           IDENTITY (10000, 1) NOT NULL,
    [IdClaveOrdenTrabajo]   VARCHAR (MAX) NULL,
    [SupervisorID]          INT           NULL,
    [IdLineaPresupuestoMes] INT           NULL,
    [IdInstalacion]         INT           NULL,
    [IdSubcontrato]         INT           NULL,
    [FechaInicio]           DATETIME      NULL,
    [FechaFin]              DATETIME      NULL,
    [IdServicioOT]          INT           NULL,
    [Cantidad]              FLOAT (53)    NULL,
    [CreadoPor]             INT           NULL,
    [CreadoEl]              DATETIME      NULL,
    [ModificadoPor]         INT           NULL,
    [ModificadoEl]          DATETIME      NULL,
    [Activo]                BIT           NULL,
    CONSTRAINT [PK_SC_ORDENTRABAJO] PRIMARY KEY CLUSTERED ([IdOrdenTrabajo] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_SC_ORDENTRABAJO_AP_USUARIO] FOREIGN KEY ([SupervisorID]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_SC_ORDENTRABAJO_CO_INSTALACION] FOREIGN KEY ([IdInstalacion]) REFERENCES [dbo].[CO_Instalacion] ([IdInstalacion]),
    CONSTRAINT [FK_SC_ORDENTRABAJO_CO_LINEAPRESUPUESTOMES] FOREIGN KEY ([IdLineaPresupuestoMes]) REFERENCES [dbo].[CO_LineaPresupuestoMes] ([IdLineaPresupuestoMes]),
    CONSTRAINT [FK_SC_ORDENTRABAJO_CO_SUBCONTRATO] FOREIGN KEY ([IdSubcontrato]) REFERENCES [dbo].[CO_Subcontrato] ([IdSubcontrato]),
    CONSTRAINT [FK_SC_ORDENTRABAJO_SC_SERVICIOOT] FOREIGN KEY ([IdServicioOT]) REFERENCES [dbo].[SC_ServicioOT] ([IdServicioOT])
);

