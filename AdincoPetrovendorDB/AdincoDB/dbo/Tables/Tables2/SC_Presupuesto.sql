CREATE TABLE [dbo].[SC_Presupuesto] (
    [IdSubContratoPresupuesto] INT      NOT NULL,
    [IdSubContrato]            INT      NOT NULL,
    [IdPresupuesto]            INT      NOT NULL,
    [CreadoPor]                INT      NOT NULL,
    [CreadoEl]                 DATETIME NOT NULL,
    CONSTRAINT [PK_SC_Presupuesto] PRIMARY KEY CLUSTERED ([IdSubContratoPresupuesto] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

