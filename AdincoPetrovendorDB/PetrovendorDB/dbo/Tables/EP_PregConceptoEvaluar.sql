CREATE TABLE [dbo].[EP_PregConceptoEvaluar] (
    [IdConceptoEvaluar]     INT            IDENTITY (1, 1) NOT NULL,
    [ConceptoEvaluarNombre] NVARCHAR (MAX) NULL,
    [valor]                 INT            NULL,
    [IdTipoDeEvaluacion]    INT            NULL,
    CONSTRAINT [PK_EP_PregConceptoEvaluar] PRIMARY KEY CLUSTERED ([IdConceptoEvaluar] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

