CREATE TABLE [dbo].[CO_MesGEActualContrato] (
    [IdMesGEActualContrato] INT      IDENTITY (1, 1) NOT NULL,
    [IdContrato]            INT      NULL,
    [MesGE]                 DATE     NULL,
    [ModificadoPor]         INT      NULL,
    [Modificado]            DATETIME NULL,
    [CreadoPor]             INT      NULL,
    CONSTRAINT [PK_MesGEContrato] PRIMARY KEY CLUSTERED ([IdMesGEActualContrato] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MesGEContrato_Contratos] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

