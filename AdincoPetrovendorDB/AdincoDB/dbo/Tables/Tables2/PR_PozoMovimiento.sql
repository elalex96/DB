CREATE TABLE [dbo].[PR_PozoMovimiento] (
    [Id]            INT           IDENTITY (1, 1) NOT NULL,
    [TipoCambio]    INT           NULL,
    [Pozo]          INT           NULL,
    [Fecha]         DATETIME      NULL,
    [Valor1]        INT           NULL,
    [Valor2]        INT           NULL,
    [ModificadoPor] VARCHAR (200) NULL,
    [Modificado]    DATETIME      NULL
);

