CREATE TABLE [dbo].[ME_EG_Conceptos] (
    [IdConcepto] INT           IDENTITY (1, 1) NOT NULL,
    [Concepto]   VARCHAR (200) NOT NULL,
    [IdModulo]   INT           NOT NULL,
    [IdRubro]    INT           NOT NULL,
    CONSTRAINT [PK_ME_EG_Conceptos] PRIMARY KEY CLUSTERED ([IdConcepto] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ME_EG_Conceptos_ME_EG_Modulos1] FOREIGN KEY ([IdModulo]) REFERENCES [dbo].[ME_EG_Modulos] ([IdModulo]),
    CONSTRAINT [FK_ME_EG_Conceptos_ME_EG_Rubros1] FOREIGN KEY ([IdRubro]) REFERENCES [dbo].[ME_EG_Rubros] ([IdRubro])
);

