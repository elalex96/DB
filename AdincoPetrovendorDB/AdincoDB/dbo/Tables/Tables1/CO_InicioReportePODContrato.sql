CREATE TABLE [dbo].[CO_InicioReportePODContrato] (
    [Id]            INT           IDENTITY (1, 1) NOT NULL,
    [FechaInicio]   DATETIME      NULL,
    [IdContrato]    INT           NULL,
    [Descripcion]   VARCHAR (150) NULL,
    [CreadoPor]     INT           NULL,
    [CreadoEl]      DATETIME      NULL,
    [ModificadoPor] INT           NULL,
    [ModificadoEl]  DATETIME      NULL,
    [Activo]        BIT           NULL,
    CONSTRAINT [PK_InicioReportePODContrato] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_InicioReportePODContratoContrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_InicioReportePODContratoCreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_InicioReportePODContratoModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

