CREATE TABLE [dbo].[TC_TerminosYCondicionesDocV2] (
    [Comentario]             NVARCHAR (MAX) NULL,
    [Documento]              NVARCHAR (MAX) NULL,
    [FechaRegistro]          DATETIME       NULL,
    [IdProveedor]            INT            NULL,
    [IdTerminosYCondiciones] INT            IDENTITY (1, 1) NOT NULL,
    [IsActivo]               BIT            NULL,
    [Nombre]                 NVARCHAR (100) NULL
);

