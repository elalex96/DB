CREATE TABLE [dbo].[CO_SAP_ImportMaxFila] (
    [IdContratista] INT      NOT NULL,
    [FilaMaxPO]     INT      NOT NULL,
    [FilaMaxSES]    INT      NOT NULL,
    [FilaMaxGR]     INT      NOT NULL,
    [ModificadoPor] INT      NOT NULL,
    [ModificadoEl]  DATETIME NOT NULL,
    CONSTRAINT [PK_CO_SAP_ImportMaxFila] PRIMARY KEY CLUSTERED ([IdContratista] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_SAP_ImportMaxFila_AP_Usuario] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_CO_SAP_ImportMaxFila_CO_Contratista] FOREIGN KEY ([IdContratista]) REFERENCES [dbo].[CO_Contratista] ([IdContratista])
);

