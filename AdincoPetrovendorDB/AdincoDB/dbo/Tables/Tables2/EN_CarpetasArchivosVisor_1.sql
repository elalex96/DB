USE [Adinco]
GO

/****** Object:  Table [dbo].[EN_CarpetasArchivosVisor]    Script Date: 03/06/2022 01:22:11 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[EN_CarpetasArchivosVisor](
	[IdElemento] [int] IDENTITY(1,1) NOT NULL,
	[IsCarpeta] [bit] NULL,
	[IsArchivo] [bit] NULL,
	[Nombre] [varchar](500) NULL,
	[IdPadre] [int] NULL,
	[CreadoPor] [int] NULL,
	[CreadoEl] [datetime] NULL,
	[Nivel] [int] NULL,
	[Activo] [int] NULL,
	[Frecuencia] [int] NULL,
	[Bucket] [varchar](1000) NULL,
	[Folder] [varchar](2000) NULL,
	[UUIDAmazon] [varchar](1000) NULL,
	[Meta] [varchar](1000) NULL,
	[SizeBytes] [float] NULL,
	[IdContrato] [int] NULL,
	[FechaEliminado] [datetime] NULL,
	[Ruta] [varchar](max) NULL,
	[Limitador] [int] NULL,
	[IdEntregable] [int] NULL,
	[AnioMes] [nvarchar](100) NULL,
 CONSTRAINT [PK_EN_CarpetasArchivosVisor] PRIMARY KEY CLUSTERED 
(
	[IdElemento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


