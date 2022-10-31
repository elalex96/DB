USE [Petrovendor]
GO

/****** Object:  Table [dbo].[WDEA_Bitacora_AdincoSAP]    Script Date: 31/10/2022 11:32:54 a. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[WDEA_Bitacora_AdincoSAP](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Fecha] [smalldatetime] NULL,
	[Mensaje] [varchar](max) NULL,
	[NoConsecutivoProcesamiento] [int] NULL,
	[IdBitacoraLectura] [int] NULL,
	[IsImportacionExitosa] [bit] NULL,
	[Purchasing_Document] [varchar](300) NULL,
 CONSTRAINT [PK_WDEA_Bitacora_AdincoSAP] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
