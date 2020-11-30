CREATE TABLE [dbo].[CO_COPADE] (
    [IdCopade]     INT            IDENTITY (1, 1) NOT NULL,
    [IdContrato]   INT            NULL,
    [NumeroCOPADE] INT            NULL,
    [FechaEmision] DATE           NULL,
    [Archivo]      NVARCHAR (255) NULL,
    [Adjunto]      IMAGE          NULL,
    CONSTRAINT [PK_COPADE] PRIMARY KEY CLUSTERED ([IdCopade] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_COPADE_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

