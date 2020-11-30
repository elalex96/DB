CREATE TABLE [dbo].[AWS_Documentos] (
    [AWSDocumentoId] INT              NOT NULL,
    [Bucket]         VARCHAR (50)     NOT NULL,
    [Folder]         VARCHAR (100)    NOT NULL,
    [UUIDAmazon]     UNIQUEIDENTIFIER NOT NULL,
    [NombreArchivo]  VARCHAR (250)    NOT NULL,
    [Meta]           VARCHAR (50)     NOT NULL,
    [CreadoPor]      INT              NOT NULL,
    [CreadoEl]       DATETIME         NOT NULL,
    [ModificadoPor]  INT              NULL,
    [ModificadoEl]   DATETIME         NULL,
    [HashSHA256]     VARCHAR (1000)   NULL,
    [Reemplazado]    BIT              NULL,
    [Peso]           INT              NULL,
    CONSTRAINT [PK_AWS_Documentos] PRIMARY KEY CLUSTERED ([AWSDocumentoId] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AWS_Documentos_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_AWS_Documentos_AP_Usuario1] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

