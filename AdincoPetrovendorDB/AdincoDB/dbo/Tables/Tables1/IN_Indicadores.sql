CREATE TABLE [dbo].[IN_Indicadores] (
    [idIndicador]   INT           IDENTITY (1, 1) NOT NULL,
    [Nombre]        VARCHAR (100) NULL,
    [Descripcion]   VARCHAR (200) NULL,
    [idAreaEmpresa] INT           NULL,
    [Titulo]        VARCHAR (100) NULL,
    [CreadoPor]     INT           NULL,
    [CreadoEl]      DATETIME      NULL,
    [ModificadoPor] INT           NULL,
    [ModificadoEl]  DATETIME      NULL,
    [Activo]        BIT           NULL,
    [Formula]       VARCHAR (500) NULL,
    CONSTRAINT [PK__IN_Indic__1F4DEAEFD8F24719] PRIMARY KEY CLUSTERED ([idIndicador] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [fk_IndicadorArea] FOREIGN KEY ([idAreaEmpresa]) REFERENCES [dbo].[IN_AreaEmpresa] ([idAreaEmpresa])
);

