CREATE TABLE [dbo].[PR_Unidades] (
    [IdUnidad]      INT           IDENTITY (1, 1) NOT NULL,
    [NombreUnidad]  VARCHAR (500) NULL,
    [Activo]        BIT           NULL,
    [CreadoPor]     INT           NULL,
    [CreadoEn]      DATETIME      NULL,
    [ModificadoPor] INT           NULL,
    [ModificadoEn]  DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdUnidad] ASC),
    CONSTRAINT [FK_PR_Unidades_UsuarioCreador] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_PR_Unidades_Usuariomodificador] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

