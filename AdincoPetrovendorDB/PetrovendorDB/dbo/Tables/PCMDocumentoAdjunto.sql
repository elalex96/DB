CREATE TABLE [dbo].[PCMDocumentoAdjunto] (
    [IdDocumento]       INT            IDENTITY (1, 1) NOT NULL,
    [IdSolicitucPedido] INT            NULL,
    [IdTipoDocumento]   INT            NULL,
    [IdProveedor]       INT            NULL,
    [Activo]            BIT            NULL,
    [CreadoPor]         INT            NULL,
    [CreadoEl]          DATETIME       NULL,
    [ModificadoPor]     INT            NULL,
    [ModificadoEl]      DATETIME       NULL,
    [Descripcion]       NVARCHAR (MAX) NULL,
    [Carpeta]           NVARCHAR (MAX) NULL,
    [Identificador]     NVARCHAR (MAX) NULL,
    [Mime]              NVARCHAR (500) NULL,
    [Extension]         NVARCHAR (500) NULL,
    [NombreDocumento]   NVARCHAR (MAX) NULL
);

