CREATE TABLE [dbo].[PC_Comercializacion_V2] (
    [IdComercializacion]    INT            IDENTITY (10000, 1) NOT NULL,
    [IdContrato]            INT            NULL,
    [FechaReporte]          DATE           NULL,
    [Factura]               NVARCHAR (255) NULL,
    [FechaFactura]          NVARCHAR (50)  NULL,
    [Sociedad]              NVARCHAR (255) NULL,
    [ValorNeto]             FLOAT (53)     NULL,
    [MonedaValNeto]         NVARCHAR (255) NULL,
    [ImporteImpuesto]       FLOAT (53)     NULL,
    [Referencia1]           NVARCHAR (255) NULL,
    [CantidadFacturada]     FLOAT (53)     NULL,
    [UniMedidaVenta]        NVARCHAR (255) NULL,
    [Material]              NVARCHAR (255) NULL,
    [Denominación]          NVARCHAR (255) NULL,
    [NoDocumento]           NVARCHAR (255) NULL,
    [Ejercicio]             NVARCHAR (255) NULL,
    [Moneda]                NVARCHAR (255) NULL,
    [TipoCambio]            NVARCHAR (255) NULL,
    [MonedaLocal]           NVARCHAR (255) NULL,
    [Referencia2]           NVARCHAR (255) NULL,
    [Importe]               FLOAT (53)     NULL,
    [ImporteML]             FLOAT (53)     NULL,
    [PosPresupuestaria]     NVARCHAR (255) NULL,
    [CentroGestor]          NVARCHAR (255) NULL,
    [CuentaMayor]           NVARCHAR (255) NULL,
    [DocCompensación]       NVARCHAR (255) NULL,
    [OrganizaciónVentas]    NVARCHAR (255) NULL,
    [CanalDistribución]     NVARCHAR (255) NULL,
    [Sector]                NVARCHAR (255) NULL,
    [Centro]                NVARCHAR (255) NULL,
    [Nombre1]               NVARCHAR (255) NULL,
    [PuestoCarga]           NVARCHAR (255) NULL,
    [Denominación1]         NVARCHAR (255) NULL,
    [Energía]               FLOAT (53)     NULL,
    [UnidadSalidaCondición] NVARCHAR (255) NULL,
    [Cliente]               NVARCHAR (255) NULL,
    [NombreCliente1]        NVARCHAR (255) NULL,
    [ImporteDolares]        FLOAT (53)     NULL,
    [MonedaDolares]         NVARCHAR (255) NULL,
    [NombreCliente2]        NVARCHAR (255) NULL,
    [OficinaVentas]         NVARCHAR (255) NULL,
    [GpoCond]               NVARCHAR (255) NULL,
    [NoOrden]               NVARCHAR (255) NULL,
    [PedCliente]            NVARCHAR (255) NULL,
    [PlanEntrega]           NVARCHAR (255) NULL,
    [FechaComp]             NVARCHAR (50)  NULL,
    [FechaPago]             NVARCHAR (50)  NULL,
    [FTesorería]            NVARCHAR (50)  NULL,
    [FDPP1]                 FLOAT (53)     NULL,
    [FDPPV]                 FLOAT (53)     NULL,
    [CreadoPor]             INT            NULL,
    [CreadoEn]              DATETIME       NULL,
    CONSTRAINT [PK_PC_Comercializacion_V2] PRIMARY KEY CLUSTERED ([IdComercializacion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PC_Comercializacion_V2_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);


GO
CREATE NONCLUSTERED INDEX [idx_Factura]
    ON [dbo].[PC_Comercializacion_V2]([Factura] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);


GO
CREATE NONCLUSTERED INDEX [idx_FechaReporte_Factura_FechaFactura]
    ON [dbo].[PC_Comercializacion_V2]([FechaReporte] ASC, [Factura] ASC, [FechaFactura] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);


GO
CREATE NONCLUSTERED INDEX [idx_Referencia1]
    ON [dbo].[PC_Comercializacion_V2]([Referencia1] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);


GO
CREATE NONCLUSTERED INDEX [idx_Nombre1]
    ON [dbo].[PC_Comercializacion_V2]([Nombre1] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);


GO
CREATE NONCLUSTERED INDEX [idx_Denominacion]
    ON [dbo].[PC_Comercializacion_V2]([Denominación] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);


GO
CREATE NONCLUSTERED INDEX [idx_FechaFactura]
    ON [dbo].[PC_Comercializacion_V2]([FechaFactura] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);

