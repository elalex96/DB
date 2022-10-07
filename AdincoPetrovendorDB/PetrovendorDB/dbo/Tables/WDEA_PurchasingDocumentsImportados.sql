USE [Petrovendor]
GO

/****** Object:  Table [dbo].[WDEA_PurchasingDocumentsImportados]    Script Date: 04/10/2022 04:44:42 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[WDEA_PurchasingDocumentsImportados](
	[IDIMPORTACION] [int] IDENTITY(1,1) NOT NULL,
	[IDLAYOUT] [int] NULL,
	[ITEM] [varchar](max) NULL,
	[PURCHASE_ORGANIZATION] [varchar](max) NULL,
	[IDCONTRATO] [int] NULL,
	[COST_CENTER] [varchar](max) NULL,
	[WBS_ELEMENT] [varchar](max) NULL,
	[IDLINEAPRESUPUESTOMES] [int] NULL,
	[OUTLINE_AGREEMENT] [varchar](max) NULL,
	[SHORT_TEXT] [varchar](max) NULL,
	[IDMATERIAL] [varchar](max) NULL,
	[VALIDITY_PER_START] [date] NULL,
	[VALIDITY_PER_END] [date] NULL,
	[DELETION_INDICATOR] [varchar](max) NULL,
	[PLANT] [varchar](max) NULL,
	[ORDER_QUANTITY] [float] NULL,
	[ORDER_UNIT] [varchar](max) NULL,
	[IDUNIDAD] [varchar](max) NULL,
	[NET_PRICE] [float] NULL,
	[CURRENCY] [varchar](max) NULL,
	[IDMONEDA] [int] NULL,
	[VENDOR_SUPPLIYING_PLANT] [varchar](max) NULL,
	[IDPROVEEDOR] [int] NULL,
	[PURCHASING_DOCUMENT] [varchar](max) NULL,
	[RELEASE_STATE] [varchar](max) NULL,
	[NAME_OF_VENDOR] [varchar](max) NULL,
	[ORDER_PRICE_UNIT] [varchar](max) NULL,
	[NET_ORDER_VALUE] [float] NULL,
	[REQUISITIONER] [varchar](max) NULL,
	[IDUSUARIOSOLICITANTE] [int] NULL,
	[TERMINOS_DE_PAGO] [varchar](max) NULL,
	[JUSTIFICACION] [varchar](max) NULL,
	[IdBitacora] [int] NULL,
	[IdPedidoADINCO] [int] NULL,
	[MECANISMO_CONTRATACION] [nvarchar](5) NULL,
 CONSTRAINT [PK_WDEA_PurchasingDocumentsImportados] PRIMARY KEY CLUSTERED 
(
	[IDIMPORTACION] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


