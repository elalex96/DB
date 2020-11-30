CREATE TABLE [dbo].[MM_SolPedArchivoAdjuntoMaterial] (
    [IdSolPedMaterialDocumentoAdj] INT            IDENTITY (1, 1) NOT NULL,
    [IdSolPedDetalle]              INT            NULL,
    [ArchivoAdjuntoMaterial]       NVARCHAR (MAX) NULL,
    [NombreArchivoAdjunto]         NVARCHAR (MAX) NULL,
    [Carpeta]                      NVARCHAR (300) NULL,
    [Identificador]                NVARCHAR (300) NULL,
    [Extension]                    NVARCHAR (300) NULL,
    [Mime]                         NVARCHAR (300) NULL,
    [Activo]                       BIT            DEFAULT ((1)) NULL,
    [CreadoPor]                    INT            NULL,
    [CreadoEl]                     DATETIME       NULL,
    [ModificadoPor]                INT            NULL,
    [ModificadoEl]                 DATETIME       NULL,
    CONSTRAINT [PK_MM_SolPedArchivoAdjuntoMaterial] PRIMARY KEY CLUSTERED ([IdSolPedMaterialDocumentoAdj] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MM_SolPedArchivoAdjuntoMaterial_MM_SolicitudPedidoDetalle] FOREIGN KEY ([IdSolPedDetalle]) REFERENCES [dbo].[MM_SolicitudPedidoDetalle] ([IdSolicitudPedidoDetalle])
);

