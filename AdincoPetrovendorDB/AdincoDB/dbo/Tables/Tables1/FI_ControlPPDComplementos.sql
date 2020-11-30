CREATE TABLE [dbo].[FI_ControlPPDComplementos] (
    [IdControlPPDC]   INT            IDENTITY (10000, 1) NOT NULL,
    [IdFactura]       INT            NOT NULL,
    [TipoComprobante] NVARCHAR (MAX) NULL,
    [UUID]            NVARCHAR (MAX) NULL,
    [MesPresentacion] DATE           NULL,
    [Activo]          BIT            NULL,
    [IdContrato]      INT            NULL,
    [CreadoPor]       INT            NULL,
    [CreadoEl]        DATETIME       NULL,
    [ModificadoPor]   INT            NULL,
    [ModificadoEl]    DATETIME       NULL
);

