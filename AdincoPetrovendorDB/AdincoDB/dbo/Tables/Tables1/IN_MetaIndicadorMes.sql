CREATE TABLE [dbo].[IN_MetaIndicadorMes] (
    [idIndicadorMeta]     INT          IDENTITY (1, 1) NOT NULL,
    [Total]               BIGINT       NULL,
    [FechaCapturado]      DATE         NULL,
    [PeriodoMes]          VARCHAR (50) NULL,
    [Periodo]             DATE         NULL,
    [Año]                 INT          NULL,
    [idIndicadorContrato] INT          NULL,
    [CreadoPor]           INT          NULL,
    [CreadoEl]            DATETIME     NULL,
    [ModificadoPor]       INT          NULL,
    [ModificadoEl]        DATETIME     NULL,
    [Activo]              BIT          NULL,
    CONSTRAINT [PK__IN_MetaI__96598907590E1730] PRIMARY KEY CLUSTERED ([idIndicadorMeta] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MetaIndicadorContrato] FOREIGN KEY ([idIndicadorContrato]) REFERENCES [dbo].[IN_IndicadorPorContrato] ([idIndicadorContrato])
);

