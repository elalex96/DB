CREATE TABLE [dbo].[ME_EG_ConceptosCompletados] (
    [IdConceptoCompletado] INT        IDENTITY (1, 1) NOT NULL,
    [IdProveedor]          INT        NOT NULL,
    [Completado]           FLOAT (53) NOT NULL,
    [IdConcepto]           INT        NOT NULL,
    CONSTRAINT [PK_ME_EG_ConceptosCompletados] PRIMARY KEY CLUSTERED ([IdConceptoCompletado] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ME_EG_ConceptosCompletados_ME_EG_Conceptos1] FOREIGN KEY ([IdConcepto]) REFERENCES [dbo].[ME_EG_Conceptos] ([IdConcepto]),
    CONSTRAINT [FK_ME_EG_ConceptosCompletados_S_Proveedor] FOREIGN KEY ([IdProveedor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor])
);

