CREATE TABLE [dbo].[SC_OrdenTrabajoDetalle] (
    [IdOrdenTrabajoDetalle]       INT        IDENTITY (10000, 1) NOT NULL,
    [IdOrdenTrabajo]              INT        NULL,
    [IdLineaProgramaActividadMes] INT        NULL,
    [IdSubcontratoDetalle]        INT        NULL,
    [Cantidad]                    FLOAT (53) NULL,
    [FechaInicio]                 DATETIME   NULL,
    [FechaFin]                    DATETIME   NULL,
    [CreadoPor]                   INT        NULL,
    [CreadoEl]                    DATETIME   NULL,
    [ModificadoPor]               INT        NULL,
    [ModificadoEl]                DATETIME   NULL,
    [Activo]                      BIT        NULL,
    CONSTRAINT [PK_SC_SC_ORDENTRABAJODETALLE] PRIMARY KEY CLUSTERED ([IdOrdenTrabajoDetalle] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_SC_ORDENTRABAJODETALLE_CO_LINEAPROGRAMAACTIVIDADMES] FOREIGN KEY ([IdLineaProgramaActividadMes]) REFERENCES [dbo].[CO_LineaProgramaActividadMes] ([IdLineaProgramaActividadMes]),
    CONSTRAINT [FK_SC_ORDENTRABAJODETALLE_CO_SUBCONTRATODETALLE] FOREIGN KEY ([IdSubcontratoDetalle]) REFERENCES [dbo].[CO_SubcontratoDetalle] ([IdSubcontratoDetalle]),
    CONSTRAINT [FK_SC_ORDENTRABAJODETALLE_SC_ORDENTRABAJO] FOREIGN KEY ([IdOrdenTrabajo]) REFERENCES [dbo].[SC_OrdenTrabajo] ([IdOrdenTrabajo])
);

