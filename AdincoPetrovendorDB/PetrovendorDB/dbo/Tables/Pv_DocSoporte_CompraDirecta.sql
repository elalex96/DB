CREATE TABLE [dbo].[Pv_DocSoporte_CompraDirecta] (
    [id]            INT            IDENTITY (1, 1) NOT NULL,
    [idFactura]     INT            NULL,
    [documento]     NVARCHAR (MAX) NULL,
    [nombreArchivo] NVARCHAR (MAX) NULL,
    [Carpeta]       NVARCHAR (300) NULL,
    [Identificador] NVARCHAR (300) NULL,
    [Extension]     NVARCHAR (300) NULL,
    [Mime]          NVARCHAR (300) NULL,
    [AMS3]          BIT            NULL,
    [EliminadoS3]   BIT            NULL,
    [isEliminado]   BIT            NULL,
	Bucket			varchar(100)
    PRIMARY KEY CLUSTERED ([id] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PV_DocSoporte_CompraDirecta] FOREIGN KEY ([idFactura]) REFERENCES [dbo].[FI_Factura] ([IdFactura]),
    CONSTRAINT [FK_PV_DocSoporte_CompraDirecta_Fi_Factura] FOREIGN KEY ([idFactura]) REFERENCES [dbo].[FI_Factura] ([IdFactura])
);

