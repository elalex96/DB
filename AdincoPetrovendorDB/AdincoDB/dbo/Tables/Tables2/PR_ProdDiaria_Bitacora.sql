CREATE TABLE [dbo].[PR_ProdDiaria_Bitacora] (
    [Id]             INT            IDENTITY (1, 1) NOT NULL,
    [NombreArchivo]  VARCHAR (2000) NULL,
    [Observacion]    VARCHAR (8000) NULL,
    [AWSId]          INT            NULL,
    [ResultadoCarga] VARCHAR (500)  NULL,
    [CreadoEn]       DATETIME       NULL,
    [CreadoPor]      INT            NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

