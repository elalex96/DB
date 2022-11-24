CREATE TABLE [dbo].[PV_ClasificacionEmpresaProveedor] (
    [IdResultado]            INT        IDENTITY (1, 1) NOT NULL,
    [IdProveedor]            INT        NOT NULL,
    [IdClasificacionEmpresa] INT        NOT NULL,
    [IdSector]               INT        NOT NULL,
    [NumEmpleados]           INT        NOT NULL,
    [ImporteVentas]          FLOAT (53) NOT NULL,
    CONSTRAINT [PK_PV_ClasificacionEmpresaProveedor] PRIMARY KEY CLUSTERED ([IdResultado] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PV_ClasificacionEmpresaProveedor_S_Proveedor] FOREIGN KEY ([IdProveedor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor])
);

