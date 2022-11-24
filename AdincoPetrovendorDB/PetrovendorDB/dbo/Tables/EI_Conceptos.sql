CREATE TABLE [dbo].[EI_Conceptos] (
    [IdConcepto]    INT            IDENTITY (1, 1) NOT NULL,
    [Concepto]      NVARCHAR (100) NOT NULL,
    [IdModulo]      INT            NOT NULL,
    [IdConceptoURL] INT            NULL,
    CONSTRAINT [PK_EI_Conceptos] PRIMARY KEY CLUSTERED ([IdConcepto] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_EI_Conceptos_EI_Modulo1] FOREIGN KEY ([IdModulo]) REFERENCES [dbo].[EI_Modulo] ([IdModulo])
);

