CREATE TABLE [dbo].[CO_ContratoEtapas] (
    [ContratoId]    INT      NOT NULL,
    [EtapaId]       INT      NOT NULL,
    [FechaInicio]   DATETIME NULL,
    [FechaFin]      DATETIME NULL,
    [Activo]        BIT      NOT NULL,
    [CreadoEl]      DATETIME NOT NULL,
    [CreadoPor]     INT      NULL,
    [ModificadoEl]  DATETIME NULL,
    [ModificadoPor] INT      NULL,
    [Carpeta]       BIT      NULL,
    CONSTRAINT [PK_CO_ContratoEtapas] PRIMARY KEY CLUSTERED ([ContratoId] ASC, [EtapaId] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_ContratoEtapas_CO_Contrato] FOREIGN KEY ([ContratoId]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_CO_ContratoEtapas_EN_Etapa] FOREIGN KEY ([EtapaId]) REFERENCES [dbo].[EN_Etapa] ([IdEtapa])
);

