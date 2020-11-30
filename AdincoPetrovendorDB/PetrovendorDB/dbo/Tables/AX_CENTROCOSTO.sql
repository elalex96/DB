CREATE TABLE [dbo].[AX_CENTROCOSTO] (
    [IdCentroCostoAx]     NVARCHAR (200) NOT NULL,
    [IdCentroCostoPetrov] INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([IdCentroCostoAx] ASC, [IdCentroCostoPetrov] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

