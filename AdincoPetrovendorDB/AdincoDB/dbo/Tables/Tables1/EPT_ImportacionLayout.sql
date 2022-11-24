CREATE TABLE [dbo].[EPT_ImportacionLayout] (
    [Id]               INT           IDENTITY (1, 1) NOT NULL,
    [ArchivoImportado] VARCHAR (MAX) NULL,
    [UsuarioId]        INT           NOT NULL,
    [ContratoId]       INT           NOT NULL,
    [CreadoEn]         DATETIME      NOT NULL,
    CONSTRAINT [PK_EPT_ImportacionLayout] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_EPT_ImportacionLayout_Contratos] FOREIGN KEY ([ContratoId]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_EPT_ImportacionLayout_Usuario] FOREIGN KEY ([UsuarioId]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

