CREATE TABLE [dbo].[PR_ParoDetalle] (
    [Id]                  INT             IDENTITY (1, 1) NOT NULL,
    [IdParo]              INT             NULL,
    [Inicio]              DATETIME        NULL,
    [Fin]                 DATETIME        NULL,
    [Duracion]            DECIMAL (24, 8) NULL,
    [ProduccionDiferida]  DECIMAL (24, 8) NULL,
    [Finalizado]          INT             NULL,
    [ProdDiaria]          INT             NULL,
    [ProduccionDiferidaB] DECIMAL (24, 8) NULL,
    CONSTRAINT [PK_PR_ParoDetalle] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

