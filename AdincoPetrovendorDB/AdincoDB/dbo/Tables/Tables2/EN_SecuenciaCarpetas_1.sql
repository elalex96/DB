USE [Adinco]
GO

/****** Object:  Table [dbo].[EN_SecuenciaCarpetas]    Script Date: 03/06/2022 01:25:35 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[EN_SecuenciaCarpetas](
	[IdCarpeta] [int] NULL,
	[Nivel] [int] NULL,
	[IdCarpetaAnterior] [int] NULL,
	[NiveAnterior] [int] NULL,
	[Frecuencia] [int] NULL,
	[IdContrato] [int] NULL,
	[IsCarpetaUsuario] [bit] NULL,
	[IsCarpetaUsuarioAnterior] [bit] NULL,
	[Ruta] [varchar](max) NULL,
	[RutaAnterior] [varchar](max) NULL,
	[Activo] [bit] NULL,
	[IdReceptorEntregable] [int] NULL,
	[IsPozo] [bit] NULL,
	[Etapa] [int] NULL,
	[AnioMes] [varchar](10) NULL,
	[IdEntregable] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


