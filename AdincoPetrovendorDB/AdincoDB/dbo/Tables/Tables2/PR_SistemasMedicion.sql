CREATE TABLE [dbo].[PR_SistemasMedicion] (
    [IdSistema]     INT           IDENTITY (1000, 1) NOT NULL,
    [IdTipoSistema] INT           NULL,
    [Marca]         VARCHAR (300) NULL,
    [Modelo]        VARCHAR (300) NULL,
    [NoSerie]       VARCHAR (300) NULL,
    [TAG]           VARCHAR (300) NULL,
    [Activo]        BIT           NULL,
    [TipoMedidor]   VARCHAR (250) NULL,
    [IdContrato]    INT           NULL,
    [CreadoPor]     INT           NULL,
    [CreadoEl]      DATETIME      NULL,
    [ModificadoPor] INT           NULL,
    [ModificadoEl]  DATETIME      NULL,
    CONSTRAINT [PK_PR_SistemaMedicion] PRIMARY KEY CLUSTERED ([IdSistema] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PR_SistemasMedicion_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_PR_SistemasMedicion_PR_TipoSistemaMedicion] FOREIGN KEY ([IdTipoSistema]) REFERENCES [dbo].[PR_TipoSistemaMedicion] ([IdTipoSistema]),
    CONSTRAINT [PR_SistemasMedicionCreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [PR_SistemasMedicionModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

