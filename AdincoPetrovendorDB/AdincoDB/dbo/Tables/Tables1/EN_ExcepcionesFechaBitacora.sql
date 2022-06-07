USE [Adinco]
GO

/****** Object:  Table [dbo].[EN_ExcepcionesFechaBitacora]    Script Date: 17/12/2021 05:38:05 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[EN_ExcepcionesFechaBitacora](
	[IdExcepcionBitacora] [int] IDENTITY(10000,1) NOT NULL,
	[IdInstanciaEntregable] [int] NULL,
	[FechaCalculadaEntregaRegAnterior] [varchar](300) NULL,
	[UsuarioId] [int] NULL,
	[ContratoId] [int] NULL,
	[FechaMovimiento] [datetime] NULL,
	[IdInstalacion] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[IdExcepcionBitacora] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[EN_ExcepcionesFechaBitacora]  WITH CHECK ADD FOREIGN KEY([ContratoId])
REFERENCES [dbo].[CO_Contrato] ([IdContrato])
GO

ALTER TABLE [dbo].[EN_ExcepcionesFechaBitacora]  WITH CHECK ADD FOREIGN KEY([UsuarioId])
REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
GO
