CREATE TABLE [dbo].[PR_Pais] (
    [Id]               INT             IDENTITY (1, 1) NOT NULL,
    [Clave]            VARCHAR (20)    NOT NULL,
    [Nombre]           VARCHAR (200)   NOT NULL,
    [Descripcion]      NVARCHAR (2000) NULL,
    [Estatus]          TINYINT         NOT NULL,
    [Idioma]           VARCHAR (20)    NULL,
    [ISO3166_alfa_2]   VARCHAR (50)    NULL,
    [ISO31661Numerico] INT             NULL,
    [ISO31661_alfa_3]  VARCHAR (50)    NULL,
    CONSTRAINT [PK_PR_Pais] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

