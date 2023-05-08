CREATE TABLE [dbo].[PR_Sistemas] (
    [IdSistema]     INT           IDENTITY (1, 1) NOT NULL,
    [NombreSistema] VARCHAR (500) NULL,
    [Activo]        BIT           NULL,
    [CreadoPor]     INT           NULL,
    [CreadoEn]      DATETIME      NULL,
    [ModificadoPor] INT           NULL,
    [ModificadoEn]  DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdSistema] ASC),
    CONSTRAINT [FK_PR_Sistemas_UsuarioCreador] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_PR_Sistemas_Usuariomodificador] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

