CREATE TABLE [dbo].[EN_TipoOperacion] (
    [idTipoOperacion] INT           IDENTITY (2, 1) NOT NULL,
    [NombreOperación] VARCHAR (100) NULL,
    CONSTRAINT [PK_TipoOperacion] PRIMARY KEY CLUSTERED ([idTipoOperacion] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

