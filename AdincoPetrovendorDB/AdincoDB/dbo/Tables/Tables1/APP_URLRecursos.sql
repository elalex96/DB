CREATE TABLE [dbo].[APP_URLRecursos] (
    [Id]          INT            IDENTITY (1, 1) NOT NULL,
    [Tipo]        VARCHAR (100)  NULL,
    [Descripcion] VARCHAR (1500) NULL,
    [URL]         VARCHAR (1500) NULL,
    [Activo]      BIT            NOT NULL
);

