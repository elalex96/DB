USE [Petrovendor]
GO

/****** Object:  Table [dbo].[DEA_UsuarioSolicitanteSAP]    Script Date: 27/08/2021 02:21:03 a. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DEA_UsuarioSolicitanteSAP](
	[IdUsuarioSolicitanteSAP] [int] IDENTITY(10000,1) NOT NULL,
	[IdUsuario] [int] NULL,
	[DescripcionSAP] [nvarchar](max) NULL,
	[CreadoEn] [datetime] NULL,
	[CreadoPor] [int] NULL,
	[IdContratista] [int] NULL,
	[IsEliminado] [bit] NULL,
	[ModificadoEn] [datetime] NULL,
	[ModificadoPor] [int] NULL,
 CONSTRAINT [PK_DEA_UsuarioSolicitanteSAP] PRIMARY KEY CLUSTERED 
(
	[IdUsuarioSolicitanteSAP] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO