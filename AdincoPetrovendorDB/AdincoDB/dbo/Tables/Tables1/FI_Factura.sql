CREATE TABLE [dbo].[FI_Factura] (
    [IdFactura]                    INT             IDENTITY (10000, 1) NOT NULL,
    [Serie]                        NVARCHAR (MAX)  NULL,
    [Folio]                        NVARCHAR (MAX)  NULL,
    [Fecha]                        DATETIME        NULL,
    [Sello]                        NVARCHAR (MAX)  NULL,
    [FormaPago]                    NVARCHAR (MAX)  NULL,
    [NoCertificado]                NVARCHAR (MAX)  NULL,
    [Certificado]                  NVARCHAR (MAX)  NULL,
    [CondicionesDePago]            NVARCHAR (MAX)  NULL,
    [SubTotal]                     MONEY           NULL,
    [Descuento]                    MONEY           NULL,
    [TipoCambio]                   MONEY           NULL,
    [Moneda]                       NVARCHAR (MAX)  NULL,
    [MontoConIva]                  MONEY           NULL,
    [TipoComprobante]              NVARCHAR (MAX)  NULL,
    [MetodoPago]                   NVARCHAR (MAX)  NULL,
    [LugarExpedicion]              NVARCHAR (MAX)  NULL,
    [NumCtaPago]                   NVARCHAR (MAX)  NULL,
    [Emisor]                       NVARCHAR (MAX)  NULL,
    [Receptor]                     NVARCHAR (MAX)  NULL,
    [UUID]                         VARCHAR (500)   NULL,
    [FechaTimbrado]                DATETIME        NULL,
    [SelloCFD]                     NVARCHAR (MAX)  NULL,
    [NoCertificadoSAT]             NVARCHAR (MAX)  NULL,
    [SelloSAT]                     NVARCHAR (MAX)  NULL,
    [Tipo]                         NVARCHAR (MAX)  NULL,
    [FechaRecepcion]               DATETIME        NULL,
    [IdSubcontratista]             INT             NULL,
    [IdMoneda]                     INT             NULL,
    [IdContrato]                   INT             NULL,
    [XML]                          NVARCHAR (MAX)  NULL,
    [Activa]                       BIT             NULL,
    [ArchivoPDF]                   NVARCHAR (MAX)  CONSTRAINT [DF_Facturas_ArchivoPDF] DEFAULT ((0)) NULL,
    [ArchivoXML]                   NVARCHAR (MAX)  NULL,
    [CreadoPor]                    INT             NULL,
    [CreadoEn]                     DATETIME        NULL,
    [ModificadoPor]                INT             NULL,
    [ModificadoEn]                 DATETIME        NULL,
    [PDF]                          VARBINARY (MAX) NULL,
    [IdReceptor]                   INT             NULL,
    [IdentificadorSIPAC]           NVARCHAR (50)   NULL,
    [NombreXML]                    NVARCHAR (MAX)  NULL,
    [IdEstudioPrecioTransfer]      INT             NULL,
    [IdDocFacturacionSIPAC]        NVARCHAR (50)   NULL,
    [ProcesadoSIPAC]               BIT             CONSTRAINT [DF_FI_Factura_ProcesadoSIPAC] DEFAULT ((0)) NULL,
    [ClaveFormaPago]               INT             CONSTRAINT [DF_FI_Factura_ClaveFormaPago] DEFAULT ((1)) NULL,
    [NoParcialidad]                INT             CONSTRAINT [DF_FI_Factura_IdTipoDocFacturacion] DEFAULT ((1)) NULL,
    [RegimenFiscal]                NVARCHAR (MAX)  NULL,
    [UsoCFDI]                      NVARCHAR (MAX)  NULL,
    [VersionCFDI]                  NVARCHAR (MAX)  NULL,
    [HashSHA256]                   NVARCHAR (300)  NULL,
    [UUIDRelacionado]              NVARCHAR (MAX)  NULL,
    [TipoRelacion]                 NVARCHAR (50)   NULL,
    [TotalImpuestosTrasladados]    MONEY           DEFAULT ((0)) NULL,
    [TotalImpuestosRetenidos]      MONEY           DEFAULT ((0)) NULL,
    [VarTransfer]                  BIT             NULL,
    [TipoComprobanteEstandarizado] VARCHAR (5)     NULL,
    [MetodoPagoEstandarizado]      VARCHAR (5)     NULL,
    CONSTRAINT [PK_Facturas] PRIMARY KEY CLUSTERED ([IdFactura] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Facturas_Contratos] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_Facturas_Monedas] FOREIGN KEY ([IdMoneda]) REFERENCES [dbo].[PV_TipoMoneda] ([IdMoneda]),
    CONSTRAINT [FK_Facturas_Subcontratistas] FOREIGN KEY ([IdSubcontratista]) REFERENCES [dbo].[PV_Subcontratista] ([IdSubcontratista]),
    CONSTRAINT [FK_FI_Factura_FI_EstudioPreciosTransfer] FOREIGN KEY ([IdEstudioPrecioTransfer]) REFERENCES [dbo].[FI_EstudioPreciosTransfer] ([IdEstudioPrecioTransfer]),
    CONSTRAINT [FK_FI_Factura_UsuarioCreado] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_FI_Factura_UsuarioModificado] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);


GO
CREATE NONCLUSTERED INDEX [idx_FacturaUUID]
    ON [dbo].[FI_Factura]([UUID] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);


GO
CREATE NONCLUSTERED INDEX [idx_FechaTimbrado]
    ON [dbo].[FI_Factura]([FechaTimbrado] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);


GO
CREATE NONCLUSTERED INDEX [IndexFacturaContrato]
    ON [dbo].[FI_Factura]([IdContrato] ASC)
    INCLUDE([IdFactura], [Serie], [Folio], [Fecha], [FormaPago], [SubTotal], [Moneda], [MontoConIva], [TipoComprobante], [MetodoPago], [LugarExpedicion], [Emisor], [UUID], [FechaRecepcion], [IdSubcontratista]) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);

