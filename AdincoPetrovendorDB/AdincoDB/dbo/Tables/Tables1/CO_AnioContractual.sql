CREATE TABLE [dbo].[CO_AnioContractual] (
    [IdAnioContractual] INT  IDENTITY (10000, 1) NOT NULL,
    [Anio]              INT  NULL,
    [Inicio]            DATE NULL,
    [Termino]           DATE NULL,
    [IdContrato]        INT  NULL,
    [CreadoPor]         INT  NULL,
    CONSTRAINT [PK_AniosContractuales] PRIMARY KEY CLUSTERED ([IdAnioContractual] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AniosContractuales_Contratos] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

