CREATE TABLE [dbo].[APP_ConfiguracionDropbox] (
    [Id]          INT            IDENTITY (1, 1) NOT NULL,
    [RootFolder]  NVARCHAR (MAX) NULL,
    [Descripcion] NVARCHAR (MAX) NULL,
    [Tipo]        NVARCHAR (600) NULL
);

