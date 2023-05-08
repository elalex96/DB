CREATE TABLE [dbo].[EI_ConceptosCompletados] (
    [IdConceptoCompletado] INT        IDENTITY (1, 1) NOT NULL,
    [IdProveedor]          INT        NOT NULL,
    [IdConceptoDetalle]    INT        NOT NULL,
    [Completado]           FLOAT (53) NOT NULL,
    CONSTRAINT [PK_EI_ConceptosCompletados] PRIMARY KEY CLUSTERED ([IdConceptoCompletado] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_EI_ConceptosCompletados_EI_ConceptosDetalle] FOREIGN KEY ([IdConceptoDetalle]) REFERENCES [dbo].[EI_ConceptosDetalle] ([IdConceptoDetalle]),
    CONSTRAINT [FK_EI_ConceptosCompletados_S_Proveedor1] FOREIGN KEY ([IdProveedor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor])
);

