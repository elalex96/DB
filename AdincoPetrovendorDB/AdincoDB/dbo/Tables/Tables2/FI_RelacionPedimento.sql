
CREATE TABLE [dbo].[FI_RelacionPedimento](
	[IdRelacionFacturaPedimento] [int] IDENTITY(1,1) NOT NULL,
	[IdFacturaPadre] [int] NOT NULL,
	[IdPedimentoHijo] [int] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_FI_RelacionPedimento] PRIMARY KEY CLUSTERED 
(
	[IdRelacionFacturaPedimento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[FI_RelacionPedimento]  WITH CHECK ADD  CONSTRAINT [FK_FI_RelacionPedimento_AP_Usuario] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
GO

ALTER TABLE [dbo].[FI_RelacionPedimento] CHECK CONSTRAINT [FK_FI_RelacionPedimento_AP_Usuario]
GO

ALTER TABLE [dbo].[FI_RelacionPedimento]  WITH CHECK ADD  CONSTRAINT [FK_FI_RelacionPedimento_FI_Factura] FOREIGN KEY([IdFacturaPadre])
REFERENCES [dbo].[FI_Factura] ([IdFactura])
GO

ALTER TABLE [dbo].[FI_RelacionPedimento] CHECK CONSTRAINT [FK_FI_RelacionPedimento_FI_Factura]
GO

ALTER TABLE [dbo].[FI_RelacionPedimento]  WITH CHECK ADD  CONSTRAINT [FK_FI_RelacionPedimento_FI_PedimentoComprobante] FOREIGN KEY([IdPedimentoHijo])
REFERENCES [dbo].[FI_PedimentoComprobante] ([IdPedimentoComprobante])
GO

ALTER TABLE [dbo].[FI_RelacionPedimento] CHECK CONSTRAINT [FK_FI_RelacionPedimento_FI_PedimentoComprobante]
GO