USE [Adinco]
GO

/****** Object:  Table [dbo].[EN_CF_SolicitUDescargaCarpetas]    Script Date: 30/05/2022 08:24:05 a. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[EN_CF_SolicitUDescargaCarpetas](
	[IdSolicitud] [int] IDENTITY(1,1) NOT NULL,
	[SolicitadoPor] [int] NULL,
	[SolicitadoEl] [datetime] NULL,
	[ContratoId] [int] NULL,
	[RutaDescargada] [nvarchar](max) NULL,
	[Procesado] [int] NULL,
	[UltimaDescarga] [datetime] NULL,
	[Bucket] [nvarchar](1000) NULL,
	[Folder] [nvarchar](1000) NULL,
	[UUIDAmazon] [nvarchar](1000) NULL,
	[NombreArchivo] [nvarchar](1000) NULL,
	[Size] [float] NULL,
	[Meta] [nvarchar](1000) NULL,
	[FechaProcesado] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[IdSolicitud] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


