CREATE TABLE [dbo].[CO_ArchivoLayoutGasto] (
    [Id]             INT      IDENTITY (1, 1) NOT NULL,
    [AWSDocumentoId] INT      NULL,
    [ContratoId]     INT      NULL,
    [CreadoEl]       DATETIME NULL,
    [CreadoPor]      INT      NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_CO_ArchivoLayoutGasto_Archivos] FOREIGN KEY ([AWSDocumentoId]) REFERENCES [dbo].[AWS_Documentos] ([AWSDocumentoId]),
    CONSTRAINT [FK_CO_ArchivoLayoutGasto_Contrato] FOREIGN KEY ([ContratoId]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_CO_ArchivoLayoutGasto_UsuarioCreador] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

