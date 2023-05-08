CREATE TABLE [dbo].[SCOC_FirmaElectronica_RESP] (
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
    [UsuarioID]          INT           NULL
);

