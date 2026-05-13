CREATE TABLE [dbo].[CO_ContratistaSubcontratista] (
    [IdContratistaSubcontratista] INT IDENTITY (10000, 1) NOT NULL,
    [IdContratista]               INT NULL,
    [IdSubcontratista]            INT NULL,
    [Relacionada]                 BIT NULL,
    CONSTRAINT [PK_CO_ContratistaSubcontratista] PRIMARY KEY CLUSTERED ([IdContratistaSubcontratista] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

