USE [Adinco]
GO

/****** Object:  Table [dbo].[EN_SecuenciaCarpetas]    Script Date: 17/01/2022 02:48:21 a. m. ******/
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
	[RutaAnterior] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


