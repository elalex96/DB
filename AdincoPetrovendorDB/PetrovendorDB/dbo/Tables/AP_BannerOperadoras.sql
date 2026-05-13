CREATE TABLE [dbo].[AP_BannerOperadoras] (
    [IdBanner]      INT            IDENTITY (1, 1) NOT NULL,
    [ImagenOperadora]  IMAGE       NOT NULL,    
	[NombreImagen]  NVARCHAR (MAX) NOT NULL, 
    [Comentario]    NVARCHAR (MAX) NOT NULL,
	[Activo]        BIT            NOT NULL,
	[Orden]			INT            NOT NULL,
    [CreadoPor]     INT            NULL,
    [CreadoEn]      DATETIME       NOT NULL,
    [ModificadoPor] INT            NULL,
    [ModificadoEn]  DATETIME       NULL,
	CONSTRAINT [PK_AP_BannerOperadoras] PRIMARY KEY CLUSTERED ([IdBanner] ASC) 
);