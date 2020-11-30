CREATE TABLE [dbo].[IN_TotalIndicadorMes] (
    [idIndicadorMes]      INT          IDENTITY (1, 1) NOT NULL,
    [Total]               BIGINT       NULL,
    [FechaCapturado]      DATE         NULL,
    [PeriodoMes]          VARCHAR (50) NULL,
    [idIndicadorContrato] INT          NULL,
    [Año]                 INT          NULL,
    [periodo]             DATE         NULL,
    [CreadoPor]           INT          NULL,
    [CreadoEl]            DATETIME     NULL,
    [ModificadoPor]       INT          NULL,
    [ModificadoEl]        DATETIME     NULL,
    [Activo]              BIT          NULL,
    CONSTRAINT [PK__IN_Total__12E46EDC11345CDD] PRIMARY KEY CLUSTERED ([idIndicadorMes] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [fk_IndicadorTotal] FOREIGN KEY ([idIndicadorContrato]) REFERENCES [dbo].[IN_IndicadorPorContrato] ([idIndicadorContrato])
);

