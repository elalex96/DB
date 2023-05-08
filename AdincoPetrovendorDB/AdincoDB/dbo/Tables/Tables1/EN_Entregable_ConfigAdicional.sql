CREATE TABLE [dbo].[EN_Entregable_ConfigAdicional] (
    [IdEntregable] INT NOT NULL,
    [Desarrollo]   BIT NULL,
    [Exploracion]  BIT NULL,
    [Evaluacion]   BIT NULL,
    [Transicion]   BIT NULL,
    [AbandonoArea] BIT NULL,
    [AbandonoPozo] BIT NULL,
    CONSTRAINT [PK_EN_Entregable_ConfigAdicional] PRIMARY KEY CLUSTERED ([IdEntregable] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

