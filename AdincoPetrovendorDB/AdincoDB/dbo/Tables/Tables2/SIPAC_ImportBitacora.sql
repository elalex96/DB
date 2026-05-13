CREATE TABLE [dbo].[SIPAC_ImportBitacora] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [IdContrato]    INT            NULL,
    [NombreArchivo] VARCHAR (1000) NOT NULL,
    [FechaCarga]    DATETIME       NOT NULL,
    [IdAWSExcel]    INT            NOT NULL,
    [MesReporte]    DATE           NOT NULL,
    [IdError]       INT            NULL,
    [CreadoPor]     INT            NOT NULL,
    CONSTRAINT [PK_SIPAC_ImportBitacora] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_SIPAC_ImportBitacora_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_SIPAC_ImportBitacora_AWS_Documentos] FOREIGN KEY ([IdAWSExcel]) REFERENCES [dbo].[AWS_Documentos] ([AWSDocumentoId]),
    CONSTRAINT [FK_SIPAC_ImportBitacora_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

