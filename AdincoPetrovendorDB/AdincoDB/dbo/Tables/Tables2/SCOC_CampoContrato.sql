CREATE TABLE [dbo].[SCOC_CampoContrato] (
    [IdContrato]    INT      NOT NULL,
    [CampoID]       INT      NOT NULL,
    [Bit_Activo]    BIT      NULL,
    [CreadoPor]     INT      NULL,
    [CreadoEn]      DATETIME NULL,
    [ModificadoPor] INT      NULL,
    [ModificadoEn]  DATETIME NULL,
    CONSTRAINT [PK_SCOC_CampoContrato] PRIMARY KEY CLUSTERED ([IdContrato] ASC, [CampoID] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_SCOC_CampoContrato_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_SCOC_CampoContrato_AP_Usuario2] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_SCOC_CampoContrato_CO_CONTRATO] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_SCOC_CampoContrato_SCOC_Campo] FOREIGN KEY ([CampoID]) REFERENCES [dbo].[SCOC_Campo] ([CampoID])
);

