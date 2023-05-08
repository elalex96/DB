CREATE TABLE [dbo].[PV_DistribuidorAutorizado] (
    [IdDistribuidorAutorizado] INT            IDENTITY (1, 1) NOT NULL,
    [NombreEmpresa]            NVARCHAR (MAX) NULL,
    [IdCreadoPor]              INT            NULL,
    [IdEditadoPor]             INT            NULL,
    [CreadoEl]                 DATETIME       NULL,
    [EditadoEl]                DATETIME       NULL,
    [IdProveedor]              INT            NULL,
    [Activo]                   BIT            NULL,
    [FechaInicioDistribucion]  DATETIME       NULL,
    [IdDocumento]              INT            NULL,
    [RFC]                      NVARCHAR (300) NULL,
    [Descripcion]              NVARCHAR (MAX) NULL,
    [Correo]                   NVARCHAR (50)  NULL,
    [Nombre]                   NVARCHAR (100) NULL,
    [Telefono]                 NVARCHAR (10)  NULL,
    CONSTRAINT [PK_PV_DistribuidorAutorizado] PRIMARY KEY CLUSTERED ([IdDistribuidorAutorizado] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

