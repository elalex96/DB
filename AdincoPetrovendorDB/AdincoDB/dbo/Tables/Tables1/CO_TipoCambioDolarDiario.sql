CREATE TABLE [dbo].[CO_TipoCambioDolarDiario] (
    [Id]             BIGINT          IDENTITY (1, 1) NOT NULL,
    [Fecha]          DATE            DEFAULT (NULL) NULL,
    [FIX]            DECIMAL (18, 4) DEFAULT ((0)) NULL,
    [PublicacionDOF] DECIMAL (18, 4) DEFAULT ((0)) NULL,
    [ParaPagos]      DECIMAL (18, 4) DEFAULT ((0)) NULL
);

