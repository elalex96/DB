CREATE TABLE [dbo].[WA_PedimentoComprobanteDetalle] (
    [IdPedimentoComprobanteDetalle] INT             NULL,
    [IdPedimentoComprobante]        INT             NULL,
    [IdUnidadMedida]                INT             NULL,
    [NumeroSerieMercancia]          NVARCHAR (50)   NULL,
    [DescripcionMercancia]          NVARCHAR (MAX)  NULL,
    [ClaseBienServicio]             NVARCHAR (150)  NULL,
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
    [IdAceptacionPedidoDetalle]     INT             NULL
);

