CREATE TABLE [dbo].[CO_PCNPeriodosPorAnios] (
    [IdPCNPeriodosPorAnios] INT        IDENTITY (10000, 1) NOT NULL,
    [IdPCNPorPeriodo]       INT        NULL,
    [Anio]                  INT        NULL,
    [PCNMinimo]             FLOAT (53) NULL,
    [CreadoPor]             INT        NULL,
    [CreadoEn]              DATETIME   NULL,
    [ModificadoPor]         INT        NULL,
    [ModificadoEl]          DATETIME   NULL
);

