CREATE TABLE [dbo].[CP_PorcentajesReparticionPC] (
    [IdPorcentajeReparticion]                 INT        IDENTITY (10000, 1) NOT NULL,
    [IdContrato]                              INT        NULL,
    [MesReporte]                              DATE       NULL,
    [PorcentajeRepPreliminarContratista]      FLOAT (53) NULL,
    [PorcentajeRepPreliminarEstado]           FLOAT (53) NULL,
    [PorcentajeRepPreliminarContratistaFinal] FLOAT (53) NULL,
    [PorcentajeRepPreliminarEstadoFinal]      FLOAT (53) NULL,
    [CreadoPor]                               INT        NULL,
    [CreadoEl]                                DATETIME   NULL,
    [ModificadoPor]                           INT        NULL,
    [ModificadoEl]                            DATETIME   NULL,
    [Activo]                                  BIT        NULL,
    CONSTRAINT [PK_CP_PorcentajesReparticionPC] PRIMARY KEY CLUSTERED ([IdPorcentajeReparticion] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CP_PorcentajesReparticionPC_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

