CREATE TABLE [dbo].[SinPermisoUrlCorreo] (
    [Id]          INT            IDENTITY (1, 1) NOT NULL,
    [Comentario]  NVARCHAR (MAX) NULL,
    [Url]         NVARCHAR (MAX) NULL,
    [IdProveedor] INT            NULL
);

