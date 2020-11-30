CREATE TABLE [dbo].[AWS_DocumentoENI] (
    [IdAWSDocumento] INT              IDENTITY (10000, 1) NOT NULL,
    [Bucket]         VARCHAR (50)     NULL,
    [Folder]         VARCHAR (100)    NULL,
    [UUIDAmazon]     UNIQUEIDENTIFIER NULL,
    [NombreArchivo]  VARCHAR (250)    NULL,
    [Meta]           VARCHAR (200)    NULL,
    [IdContrato]     INT              NULL,
    [CreadoPor]      INT              NULL,
    [CreadoEl]       DATETIME         NULL,
    [ModificadoPor]  INT              NULL,
    [ModificadoEl]   DATETIME         NULL,
    [Privado]        BIT              NULL,
    CONSTRAINT [PK_AWS_DocumentoENI] PRIMARY KEY CLUSTERED ([IdAWSDocumento] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AWS_DocumentoENI_AP_UsuarioCreado] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_AWS_DocumentoENI_AP_UsuarioModificado] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_AWS_DocumentoENI_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

