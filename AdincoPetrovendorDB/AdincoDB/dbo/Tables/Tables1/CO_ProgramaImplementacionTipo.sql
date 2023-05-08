CREATE TABLE [dbo].[CO_ProgramaImplementacionTipo] (
    [Id]            TINYINT       NOT NULL,
    [Descripcion]   VARCHAR (250) NOT NULL,
    [IsEliminado]   BIT           NOT NULL,
    [IdContratista] INT           NULL,
    [IdContrato]    INT           NULL,
    CONSTRAINT [PK_CO_ProgramaImplementacion] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    FOREIGN KEY ([IdContratista]) REFERENCES [dbo].[CO_Contratista] ([IdContratista]),
    FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

