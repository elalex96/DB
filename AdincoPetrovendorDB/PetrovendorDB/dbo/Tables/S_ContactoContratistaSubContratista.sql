CREATE TABLE [dbo].[S_ContactoContratistaSubContratista] (
    [IdContactoCS]                INT      IDENTITY (1, 1) NOT NULL,
    [IdContacto]                  INT      NULL,
    [IdContratistaSubContratista] INT      NULL,
    [IsActivo]                    BIT      NULL,
    [FechaRegistro]               DATETIME NULL,
    CONSTRAINT [PK_S_ContactoContratistaSubContratista] PRIMARY KEY CLUSTERED ([IdContactoCS] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

