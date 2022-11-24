CREATE TABLE [dbo].[CO_ContratoConfiguracion] (
    [IdContrato]          INT          NOT NULL,
    [Color_RGB]           VARCHAR (50) NULL,
    [Color_Hex]           VARCHAR (50) NULL,
    [Color_Transparencia] FLOAT (53)   NULL,
    CONSTRAINT [PK_CO_ContratoConfiguracion] PRIMARY KEY CLUSTERED ([IdContrato] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_ContratoConfiguracion_CO_CONTRATO] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

