CREATE TABLE [dbo].[FI_RestriccionFactura] (
    [IdRestriccion] INT      IDENTITY (1, 1) NOT NULL,
    [IdProveedor]   INT      NULL,
    [Excedente]     MONEY    NULL,
    [Activo]        BIT      NULL,
    [ModificadoPor] INT      NULL,
    [ModificadoEl]  DATETIME NULL,
    CONSTRAINT [PK_FI_RestriccionFactura] PRIMARY KEY CLUSTERED ([IdRestriccion] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_FI_RestriccionFactura_S_Proveedor1] FOREIGN KEY ([IdProveedor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor]),
    CONSTRAINT [FK_FI_RestriccionFactura_S_Usuario1] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[S_Usuario] ([IdUsuario])
);

