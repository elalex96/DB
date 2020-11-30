CREATE TABLE [dbo].[MM_CondicionPagoContrato] (
    [IdCondicionPagoContrato] INT IDENTITY (1, 1) NOT NULL,
    [IdCondicionPago]         INT NOT NULL,
    [IdContrato]              INT NOT NULL,
    [Activo]                  BIT NOT NULL,
    CONSTRAINT [PK_MM_CondicionPagoContrato] PRIMARY KEY CLUSTERED ([IdCondicionPagoContrato] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MM_CondicionPagoContrato_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_MM_CondicionPagoContrato_MM_CondicionPago] FOREIGN KEY ([IdCondicionPago]) REFERENCES [dbo].[MM_CondicionPago] ([IdCondicionPago])
);

