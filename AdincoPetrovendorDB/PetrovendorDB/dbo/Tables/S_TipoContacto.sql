CREATE TABLE [dbo].[S_TipoContacto] (
    [IdTipoContacto]     INT           IDENTITY (1, 1) NOT NULL,
    [NombreTipoContacto] NVARCHAR (50) NULL,
    CONSTRAINT [PK_S_TipoContacto] PRIMARY KEY CLUSTERED ([IdTipoContacto] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

