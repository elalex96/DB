CREATE TABLE [dbo].[EN_LineamientoDocumento] (
    [IdLineamientoDocumento]     INT              NOT NULL,
    [Bucket]                     VARCHAR (50)     NULL,
    [Folder]                     VARCHAR (100)    NULL,
    [UUIDAmazon]                 UNIQUEIDENTIFIER NOT NULL,
    [NombreArchivo]              VARCHAR (250)    NULL,
    [Meta]                       VARCHAR (50)     NULL,
    [CreadoPor]                  INT              NULL,
    [CreadoEl]                   DATETIME         NOT NULL,
    [ModificadoPor]              INT              NULL,
    [ModificadoEl]               DATETIME         NULL,
    [TextoDocumento]             VARCHAR (MAX)    NULL,
    [Eliminado]                  BIT              NULL,
    [IdLineamientoEntidad]       INT              NULL,
    [IdLineamientoTipoDocumento] INT              NULL,
    [NombreDocumento]            VARCHAR (100)    NULL,
    PRIMARY KEY CLUSTERED ([IdLineamientoDocumento] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_IdEntidad] FOREIGN KEY ([IdLineamientoEntidad]) REFERENCES [dbo].[EN_LineamientoEntidad] ([IdLineamientoEntidad]),
    CONSTRAINT [FK_IdTipoDocumento] FOREIGN KEY ([IdLineamientoTipoDocumento]) REFERENCES [dbo].[EN_LineamientoTipoDocumento] ([IdLineamientoTipoDocumento])
);

