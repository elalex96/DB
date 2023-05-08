CREATE TABLE [dbo].[AP_Banner] (
    [IdBanner]      INT            IDENTITY (10000, 1) NOT NULL,
    [BannerImagen]  IMAGE          NULL,
    [Activo]        BIT            NULL,
    [Comentario]    NVARCHAR (MAX) NULL,
    [CreadoPor]     INT            NULL,
    [CreadoEn]      DATETIME       NULL,
    [ModificadoPor] INT            NULL,
    [ModificadoEn]  DATETIME       NULL
);

