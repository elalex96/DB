CREATE TABLE [dbo].[CaroulseImages] (
    [IdCarouselImage] INT           NOT NULL,
    [Carpeta]         VARCHAR (100) NULL,
    [Nombre]          VARCHAR (100) NULL,
    [Activo]          BIT           NULL,
    CONSTRAINT [PK_CarouselImages] PRIMARY KEY CLUSTERED ([IdCarouselImage] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

