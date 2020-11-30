CREATE TABLE [dbo].[CO_ContratoArea] (
    [IdContrato] INT           NOT NULL,
    [NombreArea] VARCHAR (250) NULL,
    CONSTRAINT [PK_CO_ContratoArea] PRIMARY KEY CLUSTERED ([IdContrato] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_ContratoArea_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

