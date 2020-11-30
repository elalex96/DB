CREATE TABLE [dbo].[OT_LineaPresupuesto] (
    [IdOTSolicitud]         INT      NOT NULL,
    [IdLineaPresupuestoMes] INT      NOT NULL,
    [CreadoPor]             INT      NOT NULL,
    [CreadoEl]              DATETIME NOT NULL,
    CONSTRAINT [PK_OT_LineaPresupuesto] PRIMARY KEY CLUSTERED ([IdOTSolicitud] ASC, [IdLineaPresupuestoMes] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_OT_LineaPresupuesto_CO_LineaPresupuestoMes] FOREIGN KEY ([IdLineaPresupuestoMes]) REFERENCES [dbo].[CO_LineaPresupuestoMes] ([IdLineaPresupuestoMes]),
    CONSTRAINT [FK_OT_LineaPresupuesto_OT_Solicitud] FOREIGN KEY ([IdOTSolicitud]) REFERENCES [dbo].[OT_Solicitud] ([IdOTSolicitud])
);

