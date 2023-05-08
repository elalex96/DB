CREATE TABLE [dbo].[AmatitlanAuditoria] (
    [Id]               INT            IDENTITY (1, 1) NOT NULL,
    [TipoServicio]     NVARCHAR (MAX) NULL,
    [Actividad]        NVARCHAR (MAX) NULL,
    [Servicio]         NVARCHAR (MAX) NULL,
    [NombreProveedor]  NVARCHAR (MAX) NULL,
    [NumeroFactura]    NVARCHAR (MAX) NULL,
    [FechaFactura]     DATETIME       NULL,
    [Moneda]           NVARCHAR (MAX) NULL,
    [MesInforme]       NVARCHAR (MAX) NULL,
    [MesCertificado]   NVARCHAR (MAX) NULL,
    [MontoFactura]     MONEY          NULL,
    [MontoFacturaUSD]  MONEY          NULL,
    [Periodo]          NVARCHAR (MAX) NULL,
    [Estatus]          NVARCHAR (MAX) NULL,
    [IdExcel]          INT            NULL,
    [IdSubcontratista] INT            NULL,
    [IdFactura]        INT            NULL,
    [IdServicio]       INT            NULL,
    [IdPrograma]       INT            NULL,
    [TC]               FLOAT (53)     NULL,
    CONSTRAINT [PK_AmatitlanAuditoria] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

