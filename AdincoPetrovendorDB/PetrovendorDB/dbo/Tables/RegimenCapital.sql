CREATE TABLE [dbo].[RegimenCapital] (
    [IdRegimenCapital] INT          IDENTITY (1, 1) NOT NULL,
    [Regimen]          VARCHAR (20) NOT NULL,
    CONSTRAINT [PK_RegimenCapital] PRIMARY KEY CLUSTERED ([IdRegimenCapital] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

