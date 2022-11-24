CREATE TABLE [dbo].[AX_CENTROCOSTO] (
    [IdCentroCostoAx]     NVARCHAR (200) NOT NULL,
    [IdCentroCostoPetrov] INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([IdCentroCostoAx] ASC, [IdCentroCostoPetrov] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

