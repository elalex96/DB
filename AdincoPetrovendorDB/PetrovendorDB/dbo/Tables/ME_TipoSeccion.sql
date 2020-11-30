CREATE TABLE [dbo].[ME_TipoSeccion] (
    [IdTipoSeccion] INT           IDENTITY (1, 1) NOT NULL,
    [Nombre]        VARCHAR (MAX) NULL,
    CONSTRAINT [PK_ME_TipoSeccion] PRIMARY KEY CLUSTERED ([IdTipoSeccion] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

