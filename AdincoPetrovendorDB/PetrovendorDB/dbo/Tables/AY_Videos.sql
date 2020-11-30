CREATE TABLE [dbo].[AY_Videos] (
    [TituloVideo]      VARCHAR (90)  NULL,
    [DescripcionVideo] VARCHAR (200) NULL,
    [UrlVideo]         VARCHAR (MAX) NULL,
    [idVideo]          INT           IDENTITY (1, 1) NOT NULL,
    [previo]           VARCHAR (MAX) NULL,
    CONSTRAINT [PK__AY_Video__D2D0AD2AAA4CC33B] PRIMARY KEY CLUSTERED ([idVideo] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

