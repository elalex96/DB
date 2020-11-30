CREATE TABLE [dbo].[AP_Pagina] (
    [PaginaID]    INT           IDENTITY (1, 1) NOT NULL,
    [Descripcion] VARCHAR (MAX) NOT NULL,
    [ModuloID]    INT           NOT NULL,
    [URL]         VARCHAR (MAX) NOT NULL,
    [Eliminado]   BIT           NOT NULL,
    [Tag1]        VARCHAR (MAX) NOT NULL,
    [Español]     VARCHAR (50)  NULL,
    [Ingles]      VARCHAR (50)  NULL,
    [Tag2]        VARCHAR (MAX) NOT NULL,
    [Nivel]       VARCHAR (2)   NULL,
    [Padre]       INT           NULL,
    [Orden]       INT           NULL,
    [CreadoPor]   INT           NULL,
    CONSTRAINT [PK_Pagina] PRIMARY KEY CLUSTERED ([PaginaID] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Pagina_Modulo] FOREIGN KEY ([ModuloID]) REFERENCES [dbo].[AP_Modulo] ([IdModulo])
);

