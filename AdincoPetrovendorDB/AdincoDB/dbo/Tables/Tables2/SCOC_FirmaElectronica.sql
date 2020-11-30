CREATE TABLE [dbo].[SCOC_FirmaElectronica] (
    [IdFirma]            INT           IDENTITY (100, 1) NOT NULL,
    [IdContrato]         INT           NULL,
    [MesReporte]         DATE          NULL,
    [IdPermiso]          INT           NULL,
    [RFC]                VARCHAR (30)  NULL,
    [RazonSocial]        VARCHAR (300) NULL,
    [FechaVigencia]      DATETIME      NULL,
    [FechaCaducidad]     DATETIME      NULL,
    [Emisor]             VARCHAR (300) NULL,
    [SignatureAlgorithm] VARCHAR (500) NULL,
    [SerialNumber]       VARCHAR (500) NULL,
    [Comentarios]        VARCHAR (500) NULL,
    [FecMovto]           DATETIME      NULL,
    [UsuarioID]          INT           NULL,
    CONSTRAINT [PK_SCOC_FirmaElectronica] PRIMARY KEY CLUSTERED ([IdFirma] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_SCOC_FirmaElectronica_AP_permiso] FOREIGN KEY ([IdPermiso]) REFERENCES [dbo].[AP_Permiso] ([IdPermiso]),
    CONSTRAINT [FK_SCOC_FirmaElectronica_AP_Usuario] FOREIGN KEY ([UsuarioID]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_SCOC_FirmaElectronica_CO_CONTRATO] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

