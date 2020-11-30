CREATE TABLE [dbo].[ME_EG_ConceptosDetalle] (
    [IdConceptoDetalle] INT           IDENTITY (1, 1) NOT NULL,
    [IdConcepto]        INT           NOT NULL,
    [Detalle]           VARCHAR (200) NOT NULL,
    [Puntos]            FLOAT (53)    NOT NULL,
    CONSTRAINT [PK_ME_EG_ConceptosDetalle] PRIMARY KEY CLUSTERED ([IdConceptoDetalle] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ME_EG_ConceptosDetalle_ME_EG_Conceptos] FOREIGN KEY ([IdConcepto]) REFERENCES [dbo].[ME_EG_Conceptos] ([IdConcepto])
);

