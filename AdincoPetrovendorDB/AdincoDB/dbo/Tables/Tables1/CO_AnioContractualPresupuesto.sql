CREATE TABLE [dbo].[CO_AnioContractualPresupuesto] (
    [IdAnioContractualPresupuesto] INT  IDENTITY (1, 1) NOT NULL,
    [IdAnioContractual]            INT  NULL,
    [IdPresupuesto]                INT  NULL,
    [InicioVigencia]               DATE NULL,
    [FinVigencia]                  DATE NULL,
    [Activo]                       BIT  NULL,
    [CreadoPor]                    INT  NULL,
    CONSTRAINT [PK_AnioContractualPresupuesto] PRIMARY KEY CLUSTERED ([IdAnioContractualPresupuesto] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AnioContractualPresupuesto_AniosContractuales] FOREIGN KEY ([IdAnioContractual]) REFERENCES [dbo].[CO_AnioContractual] ([IdAnioContractual]),
    CONSTRAINT [FK_AnioContractualPresupuesto_Presupuestos] FOREIGN KEY ([IdPresupuesto]) REFERENCES [dbo].[CO_Presupuesto] ([IdPresupuesto])
);

