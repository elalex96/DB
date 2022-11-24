CREATE TABLE [dbo].[EN_Documentos_BitacoraReporteSASISOPA] (
    [Id]                INT           IDENTITY (1, 1) NOT NULL,
    [IdUsuario]         INT           NOT NULL,
    [IdContrato]        INT           NOT NULL,
    [FechaInicial]      DATETIME      NOT NULL,
    [FechaFinal]        DATETIME      NOT NULL,
    [Procesado]         BIT           NULL,
    [FechaCreacion]     DATETIME      NULL,
    [FechaModificacion] DATETIME      NULL,
    [ModificadoPor]     INT           NULL,
    [Server]            VARCHAR (300) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    FOREIGN KEY ([IdUsuario]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

