CREATE TABLE [dbo].[CO_ProgramaActividadDetalleMes] (
    [IdProgramaActividadDetalleMes] INT        IDENTITY (10000, 1) NOT NULL,
    [IdProgramaActividadDetalle]    INT        NULL,
    [NumeroAnio]                    INT        NULL,
    [NumeroMes]                     INT        NULL,
    [Fecha]                         DATE       NULL,
    [Cantidad]                      FLOAT (53) NULL,
    [CreadoPor]                     INT        NULL,
    [CreadoEl]                      DATETIME   NULL,
    [ModificadoPor]                 INT        NULL,
    [ModificadoEl]                  DATETIME   NULL,
    [Activo]                        BIT        NULL,
    CONSTRAINT [PK_CO_ProgramaActividadDetalleMes] PRIMARY KEY CLUSTERED ([IdProgramaActividadDetalleMes] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_ProgramaActividadDetalleMes_CO_ProgramaActividadDetalle] FOREIGN KEY ([IdProgramaActividadDetalle]) REFERENCES [dbo].[CO_ProgramaActividadDetalle] ([IdProgramaActividadDetalle])
);

