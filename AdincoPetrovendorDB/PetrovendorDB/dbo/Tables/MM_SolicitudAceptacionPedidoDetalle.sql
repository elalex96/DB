CREATE TABLE [dbo].[MM_SolicitudAceptacionPedidoDetalle](
	[IdSolicitudAceptacionPedidoDetalle] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[IdSolicitudAceptacionPedido] [int] NULL,
	[IdPedidoDetalle] [int] NULL,
	[Cantidad] [float] NULL,
	[CreadoPor] [int] NULL,
	[CreadoEl] [datetime] NULL,
	[EditadoPor] [int] NULL,
	[EditadoEl] [datetime] NULL,
	 CONSTRAINT [FK_MM_SolicitudAceptacionPedidoDetalle_MM_SolicitudAceptacionPedido] FOREIGN KEY([IdSolicitudAceptacionPedido]) REFERENCES [dbo].[MM_SolicitudAceptacionPedido] ([IdSolicitudAceptacionPedido]),
	 CONSTRAINT [FK_MM_SolicitudAceptacionPedidoDetalle_MM_PedidoDetalle] FOREIGN KEY([IdPedidoDetalle]) REFERENCES [dbo].[MM_PedidoDetalle] ([IdPedidoDetalle])
) 
GO