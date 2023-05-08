CREATE TABLE [dbo].[MM_PeticionOfertaMercadeoAdjunto] (
    [Id]                INT            IDENTITY (1, 1) NOT NULL,
    [Documento]         NVARCHAR (MAX) NULL,
    [Carpeta]           NVARCHAR (MAX) NULL,
    [Identificador]     NVARCHAR (MAX) NULL,
    [Mime]              NVARCHAR (MAX) NULL,
    [Extension]         NVARCHAR (MAX) NULL,
    [NombreDocumento]   NVARCHAR (MAX) NULL,
    [Activo]            BIT            NULL,
    [CreadoPor]         INT            NULL,
    [CreadoEl]          DATETIME       NULL,
    [ModificadoPor]     INT            NULL,
    [ModificadoEl]      DATETIME       NULL,
    [IdSolicitudPedido] INT            NULL,
    [Bucket]            VARCHAR (200)  NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

