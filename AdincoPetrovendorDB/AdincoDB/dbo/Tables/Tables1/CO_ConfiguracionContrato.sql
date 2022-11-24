CREATE TABLE [dbo].[CO_ConfiguracionContrato] (
    [IdConfCon]       INT IDENTITY (1000, 1) NOT NULL,
    [IdContrato]      INT NULL,
    [Sanciones]       BIT NULL,
    [Definiciones]    BIT NULL,
    [AltaProcesos]    BIT NULL,
    [CatalogoActProc] BIT NULL,
    PRIMARY KEY CLUSTERED ([IdConfCon] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

