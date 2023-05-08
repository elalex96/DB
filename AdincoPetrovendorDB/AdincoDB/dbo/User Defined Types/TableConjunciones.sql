CREATE TYPE [dbo].[TableConjunciones] AS TABLE (
    [id]          INT           IDENTITY (1, 1) NOT NULL,
    [palabra]     VARCHAR (500) NULL,
    [sustitucion] VARCHAR (200) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC));

