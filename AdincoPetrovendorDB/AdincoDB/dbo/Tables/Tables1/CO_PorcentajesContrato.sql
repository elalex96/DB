CREATE TABLE [dbo].[CO_PorcentajesContrato] (
    [idporcentaje]    INT            IDENTITY (10000, 1) NOT NULL,
    [PorcentajeMas]   INT            NULL,
    [PorcentajeMenos] INT            NULL,
    [idContrato]      INT            NULL,
    [PorcentajePemex] DECIMAL (6, 2) NULL,
    [PorcentajeSocio] DECIMAL (6, 2) NULL,
    PRIMARY KEY CLUSTERED ([idporcentaje] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    FOREIGN KEY ([idContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

