CREATE TABLE [dbo].[GuiasRapidas] (
    [IdGuiaRapida]    INT            IDENTITY (1, 1) NOT NULL,
    [NombreGuia]      NVARCHAR (MAX) NULL,
    [Modulo]          NVARCHAR (MAX) NULL,
    [Plataforma]      NVARCHAR (MAX) NULL,
    [ArchivoEditable] NVARCHAR (MAX) NULL,
    [Activo]          BIT            NULL,
    [Archivo]         IMAGE          NULL
);

