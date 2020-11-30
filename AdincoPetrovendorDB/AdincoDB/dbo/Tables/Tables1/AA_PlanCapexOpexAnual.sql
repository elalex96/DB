CREATE TABLE [dbo].[AA_PlanCapexOpexAnual] (
    [IdPlanCapexOpexAnual] INT   IDENTITY (1, 1) NOT NULL,
    [IdContrato]           INT   NULL,
    [Anio]                 INT   NULL,
    [CapexMMUSD]           MONEY NULL,
    [OpexMMUSD]            MONEY NULL,
    [RealCapexMMUSD]       MONEY NULL,
    [RealOpexMMUSD]        MONEY NULL,
    CONSTRAINT [PK_AA_PlanCapexOpexAnual] PRIMARY KEY CLUSTERED ([IdPlanCapexOpexAnual] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

