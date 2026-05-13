CREATE TABLE [dbo].[AA_PlanPrecioVentaHidrocarburoAnual] (
    [IdPlanPrecioVentaHidrocarburoAnual] INT   IDENTITY (1, 1) NOT NULL,
    [IdContrato]                         INT   NULL,
    [Anio]                               INT   NULL,
    [PetroleoUSDBl]                      MONEY NULL,
    [CondensadoUSDBl]                    MONEY NULL,
    [GasUSDMPc]                          MONEY NULL,
    [RealPetroleoUSDBl]                  MONEY NULL,
    [RealCondensadoUSDBl]                MONEY NULL,
    [RealGasUSDMPc]                      MONEY NULL,
    CONSTRAINT [PK_AA_PlanPrecioVentaHidrocarburoAnual] PRIMARY KEY CLUSTERED ([IdPlanPrecioVentaHidrocarburoAnual] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AA_PlanPrecioVentaHidrocarburoAnual_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

