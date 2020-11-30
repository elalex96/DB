CREATE TABLE [dbo].[ME_ResultadosTotal] (
    [IdResultadoTotal]   INT NOT NULL,
    [IdProveedorCliente] INT NOT NULL,
    [Resultado]          INT NOT NULL,
    CONSTRAINT [PK_ME_ResultadosTotal] PRIMARY KEY CLUSTERED ([IdResultadoTotal] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ME_ResultadosTotal_S_Proveedor] FOREIGN KEY ([IdProveedorCliente]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor])
);

