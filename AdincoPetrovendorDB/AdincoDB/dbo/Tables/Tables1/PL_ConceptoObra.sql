CREATE TABLE [dbo].[PL_ConceptoObra] (
    [IdConceptoObra] INT            IDENTITY (1, 1) NOT NULL,
    [ConceptoObra]   NVARCHAR (MAX) NULL,
    [CreadoPor]      INT            NULL,
    CONSTRAINT [PK_ConceptoObra] PRIMARY KEY CLUSTERED ([IdConceptoObra] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

