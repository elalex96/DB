CREATE TABLE [dbo].[S_AlmacenAccion] (
    [IdAccion] INT           NOT NULL,
    [Nombre]   VARCHAR (100) NOT NULL,
    CONSTRAINT [PK_S_AlmacenAccion] PRIMARY KEY CLUSTERED ([IdAccion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

