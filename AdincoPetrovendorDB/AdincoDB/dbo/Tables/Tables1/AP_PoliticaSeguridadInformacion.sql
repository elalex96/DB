CREATE TABLE [dbo].[AP_PoliticaSeguridadInformacion] (
    [Id]                INT           IDENTITY (1, 1) NOT NULL,
    [PoliticaSeguridad] VARCHAR (MAX) NULL,
    [Activo]            BIT           NULL,
    CONSTRAINT [PK_PoliticaSeguridadInformacion] PRIMARY KEY CLUSTERED ([Id] ASC)
);

