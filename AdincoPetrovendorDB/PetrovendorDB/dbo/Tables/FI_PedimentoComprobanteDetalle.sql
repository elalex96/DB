CREATE TABLE [dbo].[FI_PedimentoComprobanteDetalle] (
    [IdPedimentoComprobanteDetalle] INT             IDENTITY (10000, 1) NOT NULL,
    [IdPedimentoComprobante]        INT             NULL,
    [IdUnidadMedida]                INT             NULL,
    [NumeroSerieMercancia]          NVARCHAR (50)   NULL,
    [DescripcionMercancia]          NVARCHAR (MAX)  NULL,
    [ClaseBienServicio]             VARCHAR (2000)  NULL,
    [PrecioUnitario]                MONEY           NULL,
    [Cantidad]                      NUMERIC (15, 4) NULL,
    [ImporteTotal]                  MONEY           NULL,
    [CreadoPor]                     INT             NULL,
    [CreadoEn]                      DATETIME        NULL,
    [ModificadoPor]                 INT             NULL,
    [ModificadoEn]                  DATETIME        NULL,
    [IsEliminado]                   BIT             NULL,
    [IsActivo]                      BIT             NULL,
    [IsBorrador]                    BIT             NULL,
    [IdAceptacionPedido]            INT             NULL,
    [IdMaterialImportado]           INT             NULL,
    [IdAceptacionPedidoDetalle]     INT             NULL,
    CONSTRAINT [PK_IdPedimentoComprobanteDetalle] PRIMARY KEY CLUSTERED ([IdPedimentoComprobanteDetalle] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_FI_PedimentoComprobanteDetalle_FI_PedimentoComprobante] FOREIGN KEY ([IdPedimentoComprobante]) REFERENCES [dbo].[FI_PedimentoComprobante] ([IdPedimentoComprobante])
);

