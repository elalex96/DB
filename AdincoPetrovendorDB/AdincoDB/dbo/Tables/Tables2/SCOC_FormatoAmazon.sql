CREATE TABLE [dbo].[SCOC_FormatoAmazon] (
    [FormatoAmazonID] INT              IDENTITY (10000, 1) NOT NULL,
    [MesReporte]      DATE             NOT NULL,
    [OpcionReporte]   INT              NOT NULL,
    [idContrato]      INT              NOT NULL,
    [Bucket]          NVARCHAR (MAX)   NULL,
    [Folder]          NVARCHAR (MAX)   NULL,
    [UUIDAmazon]      UNIQUEIDENTIFIER NOT NULL,
    [NombreArchivo]   NVARCHAR (MAX)   NULL,
    [Meta]            NVARCHAR (MAX)   NULL,
    [CreadoPor]       INT              NULL,
    [CreadoEl]        DATETIME         NULL,
    [ModificadoPor]   INT              NULL,
    [ModificadoEl]    DATETIME         NULL,
    [Activo]          BIT              NULL,
    CONSTRAINT [PK_SCOC_FormatoAmazon] PRIMARY KEY CLUSTERED ([MesReporte] ASC, [OpcionReporte] ASC, [idContrato] ASC, [FormatoAmazonID] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_SCOC_FormatoAmazon_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_SCOC_FormatoAmazon_AP_Usuario2] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_SCOC_FormatoAmazon_CO_CONTRATO] FOREIGN KEY ([idContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [fK_SCOC_FormatoAmazon_TipoFormato] FOREIGN KEY ([OpcionReporte]) REFERENCES [dbo].[SCOC_TipoArchivos] ([IdTipoArchivo])
);

