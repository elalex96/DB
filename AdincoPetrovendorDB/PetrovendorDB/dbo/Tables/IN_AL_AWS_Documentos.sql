CREATE TABLE [dbo].[IN_AL_AWS_Documentos] (
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
    CONSTRAINT [PK_IN_AL_AWS_Documentos] PRIMARY KEY CLUSTERED ([AWSDocumentoId] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_IN_AL_AWS_Documentos_S_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[S_Usuario] ([IdUsuario]),
    CONSTRAINT [FK_IN_AL_AWS_Documentos_S_Usuario1] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[S_Usuario] ([IdUsuario])
);

