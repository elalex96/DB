CREATE TABLE [dbo].[MM_AceptacionDocumento] (
    [IdAceptacionDocumento] INT            NULL,
    [IdDocumento]           INT            NULL,
    [Comentario]            NVARCHAR (MAX) NULL,
    [NombreDocumento]       NVARCHAR (MAX) NULL,
    [Activo]                BIT            DEFAULT ((1)) NULL
);

