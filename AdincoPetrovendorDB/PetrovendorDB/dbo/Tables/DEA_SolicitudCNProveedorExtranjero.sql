CREATE TABLE [dbo].[DEA_SolicitudCNProveedorExtranjero] (
    [Id]            INT      IDENTITY (1, 1) NOT NULL,
    [IdProveedor]   INT      NULL,
    [IdContrato]    INT      NULL,
    [Activo]        BIT      NULL,
    [CreadoPor]     INT      NULL,
    [CreadoEl]      DATETIME NULL,
    [ModificadoPor] INT      NULL,
    [ModificadoEl]  DATETIME NULL
);

