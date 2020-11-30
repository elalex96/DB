CREATE TABLE [dbo].[PC_CargaLayoutPemex] (
    [IdLayout]             INT           NOT NULL,
    [IdContrato]           INT           NOT NULL,
    [IdTipoExcelPemex]     INT           NULL,
    [FechaReporte]         DATETIME      NOT NULL,
    [FileSource]           IMAGE         NOT NULL,
    [FileType]             VARCHAR (100) NOT NULL,
    [FileName]             VARCHAR (250) NOT NULL,
    [Procesado]            BIT           NOT NULL,
    [FechaProcesado]       DATETIME      NULL,
    [FechaUltimoProcesado] DATETIME      NULL,
    [CreadoEl]             DATETIME      NOT NULL,
    [CreadoPor]            INT           NOT NULL,
    CONSTRAINT [PK_PC_CargaLayoutPemex] PRIMARY KEY CLUSTERED ([IdLayout] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PC_CargaLayoutPemex_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_PC_CargaLayoutPemex_PC_TipoExcelPemex] FOREIGN KEY ([IdTipoExcelPemex]) REFERENCES [dbo].[PC_TipoExcelPemex] ([IdTipoExcelPemex])
);

