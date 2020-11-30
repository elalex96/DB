CREATE TABLE [dbo].[MM_Almacen] (
    [idAlmacen]                 INT            IDENTITY (1, 1) NOT NULL,
    [Nombre]                    NVARCHAR (MAX) NULL,
    [Clave]                     NVARCHAR (MAX) NULL,
    [PC]                        NVARCHAR (MAX) NULL,
    [Telefono]                  NVARCHAR (MAX) NULL,
    [Domicilio]                 NVARCHAR (MAX) NULL,
    [Correo]                    NVARCHAR (MAX) NULL,
    [Observaciones]             NVARCHAR (MAX) NULL,
    [Activo]                    BIT            CONSTRAINT [DF_admin_almacenes_activo] DEFAULT ((1)) NULL,
    [Responsable]               NVARCHAR (MAX) NULL,
    [FolioAutomatico]           BIT            NULL,
    [CantidadLimite]            FLOAT (53)     NULL,
    [URL]                       FLOAT (53)     NULL,
    [MetodoValuacionInventario] INT            NULL,
    [CreadoEn]                  DATETIME       NULL,
    [ModificadoPor]             INT            NULL,
    [ModificadoEn]              DATETIME       NULL,
    [CreadoPor]                 INT            NULL,
    CONSTRAINT [PK_admin_almacenes] PRIMARY KEY CLUSTERED ([idAlmacen] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

