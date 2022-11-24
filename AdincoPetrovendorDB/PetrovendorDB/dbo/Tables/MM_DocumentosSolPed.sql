CREATE TABLE [dbo].[MM_DocumentosSolPed] (
    [IdDocumento]   INT            IDENTITY (1, 1) NOT NULL,
    [IdSolPed]      INT            NOT NULL,
    [Documento]     NVARCHAR (MAX) NOT NULL,
    [NombreDoc]     VARCHAR (100)  NULL,
    [Carpeta]       NVARCHAR (300) NULL,
    [Identificador] NVARCHAR (300) NULL,
    [Extension]     NVARCHAR (300) NULL,
    [Mime]          NVARCHAR (300) NULL,
    [Activo]        BIT            NULL,
    [CreadoPor]     INT            NULL,
    [CreadoEl]      DATETIME       NULL,
    [ModificadoPor] INT            NULL,
    [ModificadoEl]  DATETIME       NULL,
    [Bucket]        VARCHAR (200)  NULL,
    CONSTRAINT [PK_MM_DocumentosSolPed] PRIMARY KEY CLUSTERED ([IdDocumento] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MM_DocumentosSolPed_MM_SolicitudPedido1] FOREIGN KEY ([IdSolPed]) REFERENCES [dbo].[MM_SolicitudPedido] ([IdSolicitudPedido])
);

