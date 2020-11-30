CREATE TABLE [dbo].[EI_ConceptosDetalle] (
    [IdConceptoDetalle] INT             IDENTITY (1, 1) NOT NULL,
    [IdConcepto]        INT             NOT NULL,
    [Detalle]           NVARCHAR (1500) NOT NULL,
    [Puntos]            FLOAT (53)      NOT NULL,
    [SoloMoral]         BIT             NOT NULL,
    CONSTRAINT [PK_EI_ConceptosDetalle] PRIMARY KEY CLUSTERED ([IdConceptoDetalle] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_EI_ConceptosDetalle_EI_Conceptos1] FOREIGN KEY ([IdConcepto]) REFERENCES [dbo].[EI_Conceptos] ([IdConcepto])
);

