CREATE TABLE [dbo].[PR_FormatoProduccionAWS] (
    [IdFormatoProduccionAWS] INT              IDENTITY (10000, 1) NOT NULL,
    [IdTipoFormato]          INT              NULL,
    [IdContrato]             INT              NULL,
    [Bucket]                 VARCHAR (1000)   NULL,
    [Folder]                 VARCHAR (1000)   NULL,
    [UUIDAmazon]             UNIQUEIDENTIFIER NULL,
    [NombreArchivo]          VARCHAR (1000)   NULL,
    [Meta]                   VARCHAR (1000)   NULL,
    [CreadoPor]              INT              NULL,
    [CreadoEl]               DATETIME         NULL,
    CONSTRAINT [PK_FormatoProduccionAWS] PRIMARY KEY CLUSTERED ([IdFormatoProduccionAWS] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Contrato_FormatoProduccionAWS] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_CreadoPor_FormatoProduccionAWS] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_Formato_FormatoProduccionAWS] FOREIGN KEY ([IdTipoFormato]) REFERENCES [dbo].[AP_PaginaLayout] ([idPagina])
);

