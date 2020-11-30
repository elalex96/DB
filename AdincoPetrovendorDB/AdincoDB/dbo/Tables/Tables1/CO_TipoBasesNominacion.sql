CREATE TABLE [dbo].[CO_TipoBasesNominacion] (
    [idTipoBase] INT            IDENTITY (1000, 1) NOT NULL,
    [Nombre]     NVARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([idTipoBase] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

