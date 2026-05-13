CREATE TABLE [dbo].[AY_Videos] (
    [IdVideo]          INT           IDENTITY (1, 1) NOT NULL,
    [TituloVideo]      VARCHAR (90)  NULL,
    [DescripcionVideo] VARCHAR (200) NULL,
    [UrlVideo]         VARCHAR (MAX) NULL,
    [IdModulo]         INT           NOT NULL,
    [Previa_Video]     IMAGE         NULL,
    CONSTRAINT [PK__AY_Video__54BA87FAA8AE1DED] PRIMARY KEY CLUSTERED ([IdVideo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_IdModulo] FOREIGN KEY ([IdModulo]) REFERENCES [dbo].[AY_Modulos] ([IdModulo])
);

