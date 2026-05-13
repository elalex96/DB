CREATE TABLE [dbo].[CO_PrecioServiciosMesCIEP] (
    [IdPrecioServiciosMes] INT        IDENTITY (10000, 1) NOT NULL,
    [IdContrato]           INT        NULL,
    [Mes]                  DATE       NULL,
    [Precio]               FLOAT (53) NULL,
    CONSTRAINT [PK_CO_PrecioServiciosMesCIEP] PRIMARY KEY CLUSTERED ([IdPrecioServiciosMes] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_PrecioServiciosMesCIEP_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

