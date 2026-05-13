CREATE TABLE [dbo].[CO_ClasificacionProductoNominacion] (
    [ProductoNominacionID] INT            IDENTITY (1000, 1) NOT NULL,
    [nombre]               NVARCHAR (MAX) NULL,
    [NombreCNH]            VARCHAR (250)  NULL,
    PRIMARY KEY CLUSTERED ([ProductoNominacionID] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

