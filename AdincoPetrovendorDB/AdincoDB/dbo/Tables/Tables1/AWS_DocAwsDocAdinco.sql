CREATE TABLE [dbo].[AWS_DocAwsDocAdinco] (
    [IdDocAwsDocAdinco] INT      IDENTITY (10000, 1) NOT NULL,
    [AWSDocumentoId]    INT      NULL,
    [IdDocAdinco]       INT      NULL,
    [IdTipoDocumento]   INT      NULL,
    [IdContrato]        INT      NULL,
    [CreadoPor]         INT      NULL,
    [CreadoEn]          DATETIME NULL,
    [ModificadoPor]     INT      NULL,
    [ModificadoEn]      DATETIME NULL,
    CONSTRAINT [PK_AWS_DocAwsDocAdinco] PRIMARY KEY CLUSTERED ([IdDocAwsDocAdinco] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AWS_DocAwsDocAdinco_AP_UsuarioCreado] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_AWS_DocAwsDocAdinco_AP_UsuarioModificado] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_AWS_DocAwsDocAdinco_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_AWS_DocAwsDocAdinco_FI_TipoDocumento] FOREIGN KEY ([IdTipoDocumento]) REFERENCES [dbo].[FI_TipoDocumento] ([id_TipoDocumento])
);

