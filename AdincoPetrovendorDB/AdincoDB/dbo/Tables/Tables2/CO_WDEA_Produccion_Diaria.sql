/****** Object:  Table [dbo].[CO_WDEA_Produccion_Diaria]    Script Date: 09/07/2021 06:11:15 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CO_WDEA_Produccion_Diaria](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdContrato] [int] NOT NULL,
	[IdAWS] [int] NULL,
	[Fecha] [datetime] NULL,
	[AceiteBrutoOG2_Balance] [float] NULL,
	[AceiteBrutoOG5_Balance] [float] NULL,
	[AceiteBrutoTotal_Balance] [float] NULL,
	[AceiteNetoOG2_Balance] [float] NULL,
	[AceiteNetoOG5_Balance] [float] NULL,
	[AceiteNetoTotal_Balance] [float] NULL,
	[CDeAguaOG2_Balance] [float] NULL,
	[CDeAguaOG5_Balance] [float] NULL,
	[CDeAguaTotal_Balance] [float] NULL,
	[GasFormOG2_Balance] [float] NULL,
	[GasFormOG5_Balance] [float] NULL,
	[GasFormTotal_Balance] [float] NULL,
	[GasInyTotalOG2_Balance] [float] NULL,
	[GasInyTotalOG5_Balance] [float] NULL,
	[GasInyTotal_Balance] [float] NULL,
	[GasInySecoOG2_Balance] [float] NULL,
	[GasInySecoOG5_Balance] [float] NULL,
	[GasInySecoTotal_Balance] [float] NULL,
	[GasInyHumedoOG2_Balance] [float] NULL,
	[GasInyHumedoOG5_Balance] [float] NULL,
	[GasInyHumedoTotal_Balance] [float] NULL,
	[AceiteBrutoOG2_PEP] [float] NULL,
	[AceiteBrutoOG5_PEP] [float] NULL,
	[AceiteBrutoTotal_PEP] [float] NULL,
	[AceiteNetoOG2_PEP] [float] NULL,
	[AceiteNetoOG5_PEP] [float] NULL,
	[AceiteNetoTotal_PEP] [float] NULL,
	[CDeAguaOG2_PEP] [float] NULL,
	[CDeAguaOG5_PEP] [float] NULL,
	[CDeAguaTotal_PEP] [float] NULL,
	[GasFormOG2_PEP] [float] NULL,
	[GasFormOG5_PEP] [float] NULL,
	[GasFormTotal_PEP] [float] NULL,
	[GasInyTotalOG2_PEP] [float] NULL,
	[GasInyTotalOG5_PEP] [float] NULL,
	[GasInyTotal_PEP] [float] NULL,
	[GasInySecoOG2_PEP] [float] NULL,
	[GasInySecoOG5_PEP] [float] NULL,
	[GasInySecoTotal_PEP] [float] NULL,
	[GasInyHumedoOG2_PEP] [float] NULL,
	[GasInyHumedoOG5_PEP] [float] NULL,
	[GasInyHumedoTotal_PEP] [float] NULL,
	[Actualizado] [bit] NULL,
	[CreadoPor] [int] NULL,
	[CreadoEl] [datetime] NULL,
	[Error] [bit] NULL,
	[Alerta] [bit] NULL,
	[Observaciones] [varchar](max) NULL,
 CONSTRAINT [PK_CO_WDEA_Produccion_Diaria] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[CO_WDEA_Produccion_Diaria]  WITH CHECK ADD  CONSTRAINT [FK_CO_WDEA_Produccion_Diaria_AP_Usuario] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
GO

ALTER TABLE [dbo].[CO_WDEA_Produccion_Diaria] CHECK CONSTRAINT [FK_CO_WDEA_Produccion_Diaria_AP_Usuario]
GO

ALTER TABLE [dbo].[CO_WDEA_Produccion_Diaria]  WITH CHECK ADD  CONSTRAINT [FK_CO_WDEA_Produccion_Diaria_AWS_Documentos] FOREIGN KEY([IdAWS])
REFERENCES [dbo].[AWS_Documentos] ([AWSDocumentoId])
GO

ALTER TABLE [dbo].[CO_WDEA_Produccion_Diaria] CHECK CONSTRAINT [FK_CO_WDEA_Produccion_Diaria_AWS_Documentos]
GO

ALTER TABLE [dbo].[CO_WDEA_Produccion_Diaria]  WITH CHECK ADD  CONSTRAINT [FK_CO_WDEA_Produccion_Diaria_CO_Contrato] FOREIGN KEY([IdContrato])
REFERENCES [dbo].[CO_Contrato] ([IdContrato])
GO

ALTER TABLE [dbo].[CO_WDEA_Produccion_Diaria] CHECK CONSTRAINT [FK_CO_WDEA_Produccion_Diaria_CO_Contrato]
GO


