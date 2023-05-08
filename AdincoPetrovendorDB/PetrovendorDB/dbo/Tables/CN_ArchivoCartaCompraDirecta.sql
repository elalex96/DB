CREATE TABLE [dbo].[CN_ArchivoCartaCompraDirecta] (
    [IdAchivoCNCD]           INT            IDENTITY (1000, 1) NOT NULL,
    [IdFactura]              INT            NULL,
    [IdDocumento]            INT            NULL,
    [nombreArchivo]          NVARCHAR (MAX) NULL,
    [Carpeta]                NVARCHAR (MAX) NULL,
    [Mime]                   NVARCHAR (MAX) NULL,
    [Extension]              NVARCHAR (MAX) NULL,
    [Identificador]          NVARCHAR (MAX) NULL,
    [CreadoPor]              INT            NULL,
    [CreadoEl]               DATETIME       NULL,
    [ModificadoPor]          INT            NULL,
    [ModificadoEl]           DATETIME       NULL,
    [IdPedido]               INT            NULL,
    [IdProveedor]            INT            NULL,
    [Activo]                 INT            NULL,
    [IdPedimentoComprobante] INT            NULL,
    [Bucket]                 VARCHAR (500)  NULL,
    PRIMARY KEY CLUSTERED ([IdAchivoCNCD] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

