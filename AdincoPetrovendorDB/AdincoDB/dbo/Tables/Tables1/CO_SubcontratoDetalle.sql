CREATE TABLE [dbo].[CO_SubcontratoDetalle] (
    [IdSubcontratoDetalle] INT           IDENTITY (10000, 1) NOT NULL,
    [IdSubcontrato]        INT           NULL,
    [IdMaterial]           INT           NULL,
    [ConceptoMaterial]     VARCHAR (MAX) NULL,
    [Volumen]              FLOAT (53)    NULL,
    [PrecioUnitario]       MONEY         NULL,
    [CreadoPor]            INT           NULL,
    [CreadoEl]             DATETIME      NULL,
    [ModificadoPor]        INT           NULL,
    [ModificadoEl]         DATETIME      NULL,
    [Activo]               BIT           NULL,
    CONSTRAINT [PK_CO_SubcontratoDetalle] PRIMARY KEY CLUSTERED ([IdSubcontratoDetalle] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_SubcontratoDetalle_CO_Subcontrato] FOREIGN KEY ([IdSubcontrato]) REFERENCES [dbo].[CO_Subcontrato] ([IdSubcontrato]),
    CONSTRAINT [FK_CO_SubcontratoDetalle_MM_Material] FOREIGN KEY ([IdMaterial]) REFERENCES [dbo].[MM_Material] ([IdMaterial])
);

