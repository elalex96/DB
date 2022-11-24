CREATE TABLE [dbo].[CO_PuntoMedicion] (
    [IdPuntoMedicion] INT            IDENTITY (10000, 1) NOT NULL,
    [IdContrato]      INT            NULL,
    [Nombre]          NVARCHAR (MAX) NULL,
    [CreadoPor]       INT            NULL,
    [CreadoEl]        DATETIME       NULL,
    [ModificadoPor]   INT            NULL,
    [ModificadoEl]    DATETIME       NULL,
    [Activo]          BIT            NULL,
    CONSTRAINT [PK_CO_PuntoMedicion] PRIMARY KEY CLUSTERED ([IdPuntoMedicion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_PuntoMedicion_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

