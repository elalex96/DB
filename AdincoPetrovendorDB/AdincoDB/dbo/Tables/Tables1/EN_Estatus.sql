CREATE TABLE [dbo].[EN_Estatus] (
    [idEstatus] INT          IDENTITY (10000, 1) NOT NULL,
    [Estatus]   VARCHAR (70) NULL,
    PRIMARY KEY CLUSTERED ([idEstatus] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

