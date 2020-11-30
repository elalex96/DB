CREATE TABLE [dbo].[PV_ReferenciasComerciales] (
    [IdReferenciaComercial]   INT            IDENTITY (1, 1) NOT NULL,
    [Empresa]                 NVARCHAR (MAX) NULL,
    [Telefono]                NVARCHAR (MAX) NULL,
    [Correo]                  NVARCHAR (MAX) NULL,
    [ImporteLineaCredito]     NVARCHAR (MAX) NULL,
    [Proveedor]               INT            NULL,
    [ReferenciaActiva]        BIT            NULL,
    [FechaAltaReferencia]     DATETIME       NULL,
    [FechaModificacion]       DATETIME       NULL,
    [IdProveedorReferenciado] INT            NULL,
    CONSTRAINT [PK_PV_ReferenciasComerciales] PRIMARY KEY CLUSTERED ([IdReferenciaComercial] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

