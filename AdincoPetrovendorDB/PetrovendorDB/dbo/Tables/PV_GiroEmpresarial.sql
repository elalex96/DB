CREATE TABLE [dbo].[PV_GiroEmpresarial] (
    [IdGiroProveedor]      INT            IDENTITY (1, 1) NOT NULL,
    [GiroProveedor]        NVARCHAR (MAX) NOT NULL,
    [PV_GiroComercialHijo] INT            NULL,
    CONSTRAINT [PK_S_GiroProveedor] PRIMARY KEY CLUSTERED ([IdGiroProveedor] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK__PV_GiroEm__PV_Gi__33647856] FOREIGN KEY ([PV_GiroComercialHijo]) REFERENCES [dbo].[PV_GiroComercialHijo] ([IdGiroProveedorHijo])
);

