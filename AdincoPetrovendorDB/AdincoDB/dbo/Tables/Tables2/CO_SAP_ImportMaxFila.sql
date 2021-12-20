
CREATE TABLE [dbo].[CO_SAP_ImportMaxFila](
	[IdContratista] [int] NOT NULL,	
	[FilaMaxPO] [int] NOT NULL,
	[FilaMaxSES] [int] NOT NULL,
	[FilaMaxGR] [int] NOT NULL,
	[ModificadoPor] [int] NOT NULL,
	[ModificadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_CO_SAP_ImportMaxFila] PRIMARY KEY CLUSTERED 
(
	[IdContratista] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CO_SAP_ImportMaxFila]  WITH CHECK ADD  CONSTRAINT [FK_CO_SAP_ImportMaxFila_AP_Usuario] FOREIGN KEY([ModificadoPor])
REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
GO

ALTER TABLE [dbo].[CO_SAP_ImportMaxFila] CHECK CONSTRAINT [FK_CO_SAP_ImportMaxFila_AP_Usuario]
GO

ALTER TABLE [dbo].[CO_SAP_ImportMaxFila]  WITH CHECK ADD  CONSTRAINT [FK_CO_SAP_ImportMaxFila_CO_Contratista] FOREIGN KEY([IdContratista])
REFERENCES [dbo].[CO_Contratista] ([IdContratista])
GO

ALTER TABLE [dbo].[CO_SAP_ImportMaxFila] CHECK CONSTRAINT [FK_CO_SAP_ImportMaxFila_CO_Contratista]
GO

