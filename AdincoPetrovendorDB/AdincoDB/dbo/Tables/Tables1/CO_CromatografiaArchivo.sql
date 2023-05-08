CREATE TABLE [dbo].[CO_CromatografiaArchivo] (
    [Id]              INT      IDENTITY (1, 1) NOT NULL,
    [CromatografiaId] INT      NULL,
    [AWSDocumentoId]  INT      NULL,
    [ContratoId]      INT      NULL,
    [Anio]            INT      NULL,
    [Mes]             INT      NULL,
    [CreadoEl]        DATETIME NULL,
    [CreadoPor]       INT      NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_CO_CromatografiaArchivo_Archivos] FOREIGN KEY ([AWSDocumentoId]) REFERENCES [dbo].[AWS_Documentos] ([AWSDocumentoId]),
    CONSTRAINT [FK_CO_CromatografiaArchivo_Contrato] FOREIGN KEY ([ContratoId]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_CO_CromatografiaArchivo_Contratografia] FOREIGN KEY ([CromatografiaId]) REFERENCES [dbo].[CO_Cromatografia] ([IdCromatografia]),
    CONSTRAINT [FK_CO_CromatografiaArchivo_UsuarioCreador] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

