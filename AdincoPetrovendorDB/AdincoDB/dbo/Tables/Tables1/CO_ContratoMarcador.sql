CREATE TABLE [dbo].[CO_ContratoMarcador] (
    [IdContratoMarcador] INT IDENTITY (10000, 1) NOT NULL,
    [IdContrato]         INT NULL,
    [IdMarcador]         INT NULL,
    CONSTRAINT [PK_CO_ContratoMarcador] PRIMARY KEY CLUSTERED ([IdContratoMarcador] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

