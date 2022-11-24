CREATE TABLE [dbo].[AWS_DropboxCredenciales] (
    [IdContrato]       INT           NOT NULL,
    [AccessTokenValue] VARCHAR (MAX) NULL,
    [RootDefault]      VARCHAR (MAX) NULL,
    [CreadoEl]         DATETIME      NULL,
    [CreadoPor]        INT           NULL,
    CONSTRAINT [PK_AWS_DropboxCredenciales] PRIMARY KEY CLUSTERED ([IdContrato] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AWS_DropboxCredenciales_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_AWS_DropboxCredenciales_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

