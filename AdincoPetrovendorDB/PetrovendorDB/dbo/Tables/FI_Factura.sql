CREATE TABLE [dbo].[FI_Factura] (
    [IdFactura]               INT             IDENTITY (10000, 1) NOT NULL,
    [Serie]                   NVARCHAR (MAX)  NULL,
    [Folio]                   NVARCHAR (MAX)  NULL,
    [Fecha]                   DATETIME        NULL,
    [Sello]                   NVARCHAR (MAX)  NULL,
    [FormaPago]               NVARCHAR (MAX)  NULL,
    [NoCertificado]           NVARCHAR (MAX)  NULL,
    [Certificado]             NVARCHAR (MAX)  NULL,
    [CondicionesDePago]       NVARCHAR (MAX)  NULL,
    [SubTotal]                MONEY           NULL,
    [Descuento]               MONEY           NULL,
    [TipoCambio]              MONEY           NULL,
    [Moneda]                  NVARCHAR (MAX)  NULL,
    [MontoConIva]             DECIMAL (18, 4) NULL,
    [TipoComprobante]         NVARCHAR (MAX)  NULL,
    [MetodoPago]              NVARCHAR (MAX)  NULL,
    [LugarExpedicion]         NVARCHAR (MAX)  NULL,
    [NumCtaPago]              NVARCHAR (MAX)  NULL,
    [Emisor]                  NVARCHAR (MAX)  NULL,
    [Receptor]                NVARCHAR (MAX)  NULL,
    [UUID]                    VARCHAR (500)   NULL,
    [FechaTimbrado]           DATETIME        NULL,
    [SelloCFD]                NVARCHAR (MAX)  NULL,
    [NoCertificadoSAT]        NVARCHAR (MAX)  NULL,
    [SelloSAT]                NVARCHAR (MAX)  NULL,
    [Tipo]                    NVARCHAR (MAX)  NULL,
    [FechaRecepcion]          DATETIME        NULL,
    [IdSubcontratista]        INT             NULL,
    [IdMoneda]                INT             NULL,
    [IdContrato]              INT             NULL,
    [XML]                     NVARCHAR (MAX)  NULL,
    [Activa]                  BIT             NULL,
    [ArchivoPDF]              NVARCHAR (MAX)  NULL,
    [ArchivoXML]              NVARCHAR (MAX)  NULL,
    [CreadoPor]               INT             NULL,
    [CreadoEn]                DATETIME        NULL,
    [ModificadoPor]           INT             NULL,
    [ModificadoEn]            DATETIME        NULL,
    [PDF]                     VARBINARY (MAX) NULL,
    [IdReceptor]              INT             NULL,
    [IdentificadorSIPAC]      VARCHAR (50)    NULL,
    [NombreXML]               NVARCHAR (MAX)  NULL,
    [IdEstudioPrecioTransfer] INT             NULL,
    [IdDocFacturacionSIPAC]   NVARCHAR (50)   NULL,
    [ProcesadoSIPAC]          BIT             NULL,
    [ClaveFormaPago]          INT             NULL,
    [IdEstatusEnviado]        INT             NULL,
    [FechaEnvio]              DATETIME        NULL,
    [ComprobantePDFByte]      IMAGE           NULL,
    [ComprobanteXMLByte]      IMAGE           NULL,
    [IdTipoPedido]            INT             NULL,
    [ResponseAdinco]          NVARCHAR (MAX)  NULL,
    [IsEliminado]             BIT             NULL,
    [EliminadoPor]            INT             NULL,
    [EliminadoEL]             DATETIME        NULL,
    [ComentarioEliminado]     NVARCHAR (MAX)  NULL,
    [IdEliminado]             INT             NULL,
    [IdLectorXMLSAT]          INT             NULL,
    [ErroSAT]                 NVARCHAR (MAX)  NULL,
    CONSTRAINT [PK_Facturas] PRIMARY KEY CLUSTERED ([IdFactura] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);


GO
CREATE NONCLUSTERED INDEX [idx_FacturaUUID]
    ON [dbo].[FI_Factura]([UUID] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);


GO
CREATE NONCLUSTERED INDEX [<Factura, sysname,>]
    ON [dbo].[FI_Factura]([Activa] ASC, [UUID] ASC)
    INCLUDE([IdFactura], [IsEliminado]) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);

