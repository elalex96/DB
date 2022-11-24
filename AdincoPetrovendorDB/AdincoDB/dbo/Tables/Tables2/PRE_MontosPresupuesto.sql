CREATE TABLE [dbo].[PRE_MontosPresupuesto] (
    [IdMontosPresupuestos] INT   IDENTITY (1, 1) NOT NULL,
    [IdContrato]           INT   NOT NULL,
    [IdTipo]               INT   NOT NULL,
    [IdEscenario]          INT   NOT NULL,
    [IdAnio]               INT   NOT NULL,
    [IdSubactividad]       INT   NOT NULL,
    [MontoBase]            MONEY NULL,
    [MontoContingente]     MONEY NULL,
    [MontoReportadoSIPAC]  MONEY NULL,
    CONSTRAINT [PK_PRE_MontosPresupuesto] PRIMARY KEY CLUSTERED ([IdMontosPresupuestos] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

