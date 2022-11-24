CREATE TABLE [dbo].[FI_RelacionRefacturas] (
    [idRelacionFactura] INT  IDENTITY (10000, 1) NOT NULL,
    [idFacturaPadre]    INT  NOT NULL,
    [idFacturaHijo]     INT  NOT NULL,
    [MesPresentacion]   DATE NULL,
    CONSTRAINT [PK__FI_Relac__41799AB5A482549E] PRIMARY KEY CLUSTERED ([idRelacionFactura] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [fk_idfacturahijo] FOREIGN KEY ([idFacturaHijo]) REFERENCES [dbo].[FI_Factura] ([IdFactura]),
    CONSTRAINT [FK_IdFacturaPadre] FOREIGN KEY ([idFacturaPadre]) REFERENCES [dbo].[FI_Factura] ([IdFactura])
);

