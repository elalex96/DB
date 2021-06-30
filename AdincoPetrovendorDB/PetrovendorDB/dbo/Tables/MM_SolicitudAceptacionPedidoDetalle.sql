CREATE TABLE [dbo].[MM_SolicitudAceptacionPedidoDetalle](
	[IdSolicitudAceptacionPedidoDetalle] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[IdSolicitudAceptacionPedido] [int] NULL,
	[IdPedidoDetalle] [int] NULL,
	[Cantidad] [float] NULL,
	[CreadoPor] [int] NULL,
	[CreadoEl] [datetime] NULL,
	[EditadoPor] [int] NULL,
	[EditadoEl] [datetime] NULL
) 
GO