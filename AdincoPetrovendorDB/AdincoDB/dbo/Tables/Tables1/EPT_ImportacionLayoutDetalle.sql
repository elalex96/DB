CREATE TABLE [dbo].[EPT_ImportacionLayoutDetalle] (
    [Id]                     INT           IDENTITY (1, 1) NOT NULL,
    [ImportacionLayoutId]    INT           NOT NULL,
    [Contratista]            VARCHAR (MAX) NULL,
    [Contrato]               VARCHAR (MAX) NULL,
    [IdentificadorDocumento] VARCHAR (MAX) NULL,
    [NombreDocumento]        VARCHAR (MAX) NULL,
    [Mes]                    INT           NULL,
    [Anio]                   INT           NULL,
    [CreadoEn]               DATETIME      NOT NULL,
    CONSTRAINT [PK_EPT_ImportacionLayoutDetalle] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_EPT_ImportacionLayoutDetalle_Importacion] FOREIGN KEY ([ImportacionLayoutId]) REFERENCES [dbo].[EPT_ImportacionLayout] ([Id])
);

