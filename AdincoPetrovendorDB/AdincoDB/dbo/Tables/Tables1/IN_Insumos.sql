CREATE TABLE [dbo].[IN_Insumos] (
    [idInsumo]      INT          IDENTITY (1, 1) NOT NULL,
    [NombreInsumo]  VARCHAR (50) NULL,
    [ValorFormula]  VARCHAR (50) NULL,
    [CreadoPor]     INT          NULL,
    [CreadoEl]      DATETIME     NULL,
    [ModificadoPor] INT          NULL,
    [ModificadoEl]  DATETIME     NULL,
    [Activo]        BIT          NULL,
    CONSTRAINT [PK__IN_Insum__215CA054B5EBDA3F] PRIMARY KEY CLUSTERED ([idInsumo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

