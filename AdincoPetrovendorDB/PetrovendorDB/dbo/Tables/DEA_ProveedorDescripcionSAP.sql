CREATE TABLE [dbo].[DEA_ProveedorDescripcionSAP] (
    [IdProveedorDescripcionSAP] INT            IDENTITY (10000, 1) NOT NULL,
    [IdProveedor]               INT            NULL,
    [DescripcionSAP]            NVARCHAR (MAX) NULL,
    [CreadoEn]                  DATETIME       NULL,
    [CreadoPor]                 INT            NULL,
    [IdContratista]             INT            NULL,
    [IsEliminado]               BIT            NULL,
    [ModificadoEn]              DATETIME       NULL,
    [ModificadoPor]             INT            NULL,
    CONSTRAINT [PK_DEAProveedorDescripcionSAP] PRIMARY KEY CLUSTERED ([IdProveedorDescripcionSAP] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_DEA_ProveedorDescripcionSAP_S_Proveedor] FOREIGN KEY ([IdProveedor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor])
);

