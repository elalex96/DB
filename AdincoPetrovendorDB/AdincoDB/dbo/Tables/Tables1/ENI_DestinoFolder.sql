CREATE TABLE [dbo].[ENI_DestinoFolder] (
    [IdDestinoFolder] INT           IDENTITY (10000, 1) NOT NULL,
    [Nombre]          VARCHAR (50)  NULL,
    [Descripcion]     VARCHAR (MAX) NULL,
    [IdContrato]      INT           NULL,
    [Activo]          BIT           NULL,
    [CreadoPor]       INT           NULL,
    [CreadoEl]        DATETIME      NULL,
    [ModificadoPor]   INT           NULL,
    [ModificadoEl]    DATETIME      NULL,
    CONSTRAINT [PK_ENI_DestinoFolder] PRIMARY KEY CLUSTERED ([IdDestinoFolder] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ENI_DestinoFolder_AP_UsuarioCreado] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_ENI_DestinoFolder_AP_UsuarioModificado] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_ENI_DestinoFolder_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

