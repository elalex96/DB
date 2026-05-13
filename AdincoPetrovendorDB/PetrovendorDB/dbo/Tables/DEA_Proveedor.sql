CREATE TABLE [dbo].[DEA_Proveedor] (
    [IdProveedor]   INT            NULL,
    [RFC]           NVARCHAR (MAX) NULL,
    [Observaciones] NVARCHAR (MAX) NULL,
    [Activo]        BIT            NULL,
    CONSTRAINT [FK_DEA_Proveedor_S_Proveedor] FOREIGN KEY ([IdProveedor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor])
);

