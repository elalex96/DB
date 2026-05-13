CREATE TABLE [dbo].[JA_EncabezadoComentarios] (
    [CreadoPor]          INT            NULL,
    [FechaCreado]        DATETIME       NULL,
    [IdEncabezado]       INT            IDENTITY (1, 1) NOT NULL,
    [IdOferta]           INT            NULL,
    [IdSolPed]           INT            NULL,
    [Nombre]             NVARCHAR (MAX) NULL,
    [Paginas]            NVARCHAR (MAX) NULL,
    [Pregunta]           NVARCHAR (MAX) NULL,
    [PuntosBases]        NVARCHAR (MAX) NULL,
    [IdProveedorCreador] INT            NULL,
    [IdContratoCreador]  INT            NULL,
    [ModificadoPor]      INT            NULL,
    [ModificadoEl]       DATETIME       NULL
);

