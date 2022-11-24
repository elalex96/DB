CREATE TABLE [dbo].[ME_TiposRespuesta] (
    [IdTipoRespuesta] INT           IDENTITY (1, 1) NOT NULL,
    [Nombre]          VARCHAR (MAX) NOT NULL,
    [Descripcion]     VARCHAR (MAX) NULL,
    CONSTRAINT [PK_ME_TiposRespuesta] PRIMARY KEY CLUSTERED ([IdTipoRespuesta] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

