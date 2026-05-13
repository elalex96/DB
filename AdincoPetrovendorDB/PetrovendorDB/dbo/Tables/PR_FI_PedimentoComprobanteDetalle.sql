CREATE TABLE [dbo].[PR_FI_PedimentoComprobanteDetalle] (
    [IdPedimentoComprobanteDetalle] INT             NOT NULL,
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
    [IdEliminacion]                 INT             NULL,
    [IdReciclaje]                   INT             IDENTITY (1, 1) NOT NULL
);

