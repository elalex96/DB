USE [Adinco]
GO

/****** Object:  Table [dbo].[EN_CarpetasArchivosVisor]    Script Date: 17/01/2022 02:47:02 a. m. ******/
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
 CONSTRAINT [PK_EN_CarpetasArchivosVisor] PRIMARY KEY CLUSTERED 
(
	[IdElemento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


