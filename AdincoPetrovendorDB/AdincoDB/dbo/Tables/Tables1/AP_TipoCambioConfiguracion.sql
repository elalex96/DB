CREATE TABLE [dbo].[AP_TipoCambioConfiguracion] (
    [TipoCambioConfiguracionId] BIGINT        IDENTITY (1, 1) NOT NULL,
    [Hora]                      VARCHAR (8)   NULL,
    [Url]                       VARCHAR (300) NULL,
    [FrecuenciaDia]             INT           NULL,
    PRIMARY KEY CLUSTERED ([TipoCambioConfiguracionId] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

