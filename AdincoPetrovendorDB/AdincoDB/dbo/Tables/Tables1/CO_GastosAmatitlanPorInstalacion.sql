CREATE TABLE [dbo].[CO_GastosAmatitlanPorInstalacion] (
    [Tipo de Servicio]       NVARCHAR (255) NULL,
    [Actividad]              NVARCHAR (255) NULL,
    [Rubro]                  NVARCHAR (255) NULL,
    [Clasificación]          NVARCHAR (255) NULL,
    [Servicio]               NVARCHAR (255) NULL,
    [Proveedor]              NVARCHAR (255) NULL,
    [No Factura]             NVARCHAR (255) NULL,
    [InstalacionProgramada]  NVARCHAR (255) NULL,
    [FechaInicio Programada] DATETIME       NULL,
    [FechaFin Programada]    DATETIME       NULL,
    [OrdenInterna]           NVARCHAR (255) NULL,
    [InstalacionEjecutada]   NVARCHAR (255) NULL,
    [FechaInicio Ejecución]  DATETIME       NULL,
    [FechaFin Ejecución]     DATETIME       NULL,
    [ActaEntrega]            FLOAT (53)     NULL,
    [MontoGE]                MONEY          NULL
);

