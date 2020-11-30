CREATE TABLE [dbo].[PV_CondicionesPago] (
    [IdCondicionPago]             INT IDENTITY (1, 1) NOT NULL,
    [IdContratistaSubContratista] INT NOT NULL,
    [Contado]                     BIT NOT NULL,
    [Credito]                     BIT NOT NULL,
    [Anticipo]                    BIT NOT NULL,
    [DiasCredito]                 INT NULL,
    [PorcentajeAnticipo]          INT NULL,
    CONSTRAINT [PK_PV_CondicionesPago] PRIMARY KEY CLUSTERED ([IdCondicionPago] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PV_CondicionesPago_PV_ContratistaSubContratista] FOREIGN KEY ([IdContratistaSubContratista]) REFERENCES [dbo].[PV_ContratistaSubContratista] ([IdRelacion])
);

