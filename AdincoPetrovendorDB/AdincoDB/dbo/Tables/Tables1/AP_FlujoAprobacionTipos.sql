CREATE TABLE [dbo].[AP_FlujoAprobacionTipos] (
    [TipoFlujoAprobacionId] SMALLINT      NOT NULL,
    [Descripcion]           VARCHAR (250) NOT NULL,
    [CreadoEl]              DATETIME      NOT NULL,
    CONSTRAINT [PK_AP_FlujoAprobacionTipos] PRIMARY KEY CLUSTERED ([TipoFlujoAprobacionId] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

