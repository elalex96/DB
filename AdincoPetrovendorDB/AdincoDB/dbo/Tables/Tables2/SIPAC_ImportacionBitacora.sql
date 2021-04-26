/****** Object:  Table [dbo].[SIPAC_ImportBitacora]    Script Date: 19/04/2021 09:29:30 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SIPAC_ImportBitacora](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdContrato] [int] NULL,
	[NombreArchivo] [varchar](1000) NOT NULL,
	[FechaCarga] [datetime] NOT NULL,
	[IdAWSExcel] [int] NOT NULL,
	[MesReporte] [date] NOT NULL,
	[IdError] [int] NULL,
	[CreadoPor] [int] NOT NULL,
 CONSTRAINT [PK_SIPAC_ImportBitacora] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[SIPAC_ImportBitacora]  WITH CHECK ADD  CONSTRAINT [FK_SIPAC_ImportBitacora_AP_BitacoraErrores] FOREIGN KEY([IdError])
REFERENCES [dbo].[AP_BitacoraErrores] ([IdError])
GO

ALTER TABLE [dbo].[SIPAC_ImportBitacora] CHECK CONSTRAINT [FK_SIPAC_ImportBitacora_AP_BitacoraErrores]
GO

ALTER TABLE [dbo].[SIPAC_ImportBitacora]  WITH CHECK ADD  CONSTRAINT [FK_SIPAC_ImportBitacora_AP_Usuario] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
GO

ALTER TABLE [dbo].[SIPAC_ImportBitacora] CHECK CONSTRAINT [FK_SIPAC_ImportBitacora_AP_Usuario]
GO

ALTER TABLE [dbo].[SIPAC_ImportBitacora]  WITH CHECK ADD  CONSTRAINT [FK_SIPAC_ImportBitacora_AWS_Documentos] FOREIGN KEY([IdAWSExcel])
REFERENCES [dbo].[AWS_Documentos] ([AWSDocumentoId])
GO

ALTER TABLE [dbo].[SIPAC_ImportBitacora] CHECK CONSTRAINT [FK_SIPAC_ImportBitacora_AWS_Documentos]
GO

ALTER TABLE [dbo].[SIPAC_ImportBitacora]  WITH CHECK ADD  CONSTRAINT [FK_SIPAC_ImportBitacora_CO_Contrato] FOREIGN KEY([IdContrato])
REFERENCES [dbo].[CO_Contrato] ([IdContrato])
GO

ALTER TABLE [dbo].[SIPAC_ImportBitacora] CHECK CONSTRAINT [FK_SIPAC_ImportBitacora_CO_Contrato]
GO


