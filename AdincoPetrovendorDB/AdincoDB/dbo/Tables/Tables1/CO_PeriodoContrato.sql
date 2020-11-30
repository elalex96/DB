CREATE TABLE [dbo].[CO_PeriodoContrato] (
    [IdPeriodo]     INT            IDENTITY (10000, 1) NOT NULL,
    [IdContrato]    INT            NULL,
    [NombrePeriodo] NVARCHAR (MAX) NULL,
    [Inicio]        DATE           NULL,
    [Fin]           DATE           NULL,
    [CreadoPor]     INT            NULL,
    [CreadoEl]      DATETIME       NULL,
    [ModificadoPor] INT            NULL,
    [ModificadoEl]  DATETIME       NULL,
    [Activo]        BIT            NULL,
    CONSTRAINT [PK_CO_PeriodoContrato] PRIMARY KEY CLUSTERED ([IdPeriodo] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_PeriodoContrato_AP_Usuario] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_CO_PeriodoContrato_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

