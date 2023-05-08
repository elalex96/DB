CREATE TABLE [dbo].[CO_ArchivoLayoutGastoBitacora] (
    [Id]             INT      IDENTITY (1, 1) NOT NULL,
    [AWSDocumentoId] INT      NULL,
    [GastoId]        INT      NULL,
    [CreadoEl]       DATETIME NULL,
    [CreadoPor]      INT      NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_CO_ArchivoLayoutGastoBitacora_Archivos] FOREIGN KEY ([AWSDocumentoId]) REFERENCES [dbo].[AWS_Documentos] ([AWSDocumentoId]),
    CONSTRAINT [FK_CO_ArchivoLayoutGastoBitacora_GastoId] FOREIGN KEY ([GastoId]) REFERENCES [dbo].[CO_Registro] ([IdRegistro]),
    CONSTRAINT [FK_CO_ArchivoLayoutGastoBitacora_UsuarioCreador] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

