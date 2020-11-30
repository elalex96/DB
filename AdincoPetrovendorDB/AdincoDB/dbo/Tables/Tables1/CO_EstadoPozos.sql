CREATE TABLE [dbo].[CO_EstadoPozos] (
    [idEstatus]   INT          IDENTITY (1, 1) NOT NULL,
    [TipoEstatus] VARCHAR (70) NULL,
    [Descripcion] VARCHAR (70) NULL,
    [Abreviatura] VARCHAR (20) NULL,
    [Color]       VARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([idEstatus] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

