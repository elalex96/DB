CREATE TABLE [dbo].[CO_ContratoSocio] (
    [IdContrato]         INT            NOT NULL,
    [IdContratistaSocio] INT            NULL,
    [Activo]             BIT            NULL,
    [CreadoPor]          INT            NULL,
    [CreadoEn]           DATETIME       NULL,
    [ModificadoPor]      INT            NULL,
    [ModificadoEn]       DATETIME       NULL,
    [UrlDoc]             VARCHAR (2500) NULL,
    CONSTRAINT [PK_CO_ContratoSocio] PRIMARY KEY CLUSTERED ([IdContrato] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_ContratoSocio_Contratista] FOREIGN KEY ([IdContratistaSocio]) REFERENCES [dbo].[CO_Contratista] ([IdContratista]),
    CONSTRAINT [FK_CO_ContratoSocio_CONTRATO] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

