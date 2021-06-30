CREATE TABLE [dbo].[MM_SolicitudAceptacionPedido](
	[IdSolicitudAceptacionPedido] [int] IDENTITY(1000,1) NOT NULL PRIMARY KEY,
	[IdProveedorVenta] [int] NULL,
	[IdPedido] [int] NULL,
	[IdAceptacionPedido] [int] NULL,
	[Comentario] [nvarchar](max) NULL,
	[NombreUsuarioEntrega] [nvarchar](300) NULL,	
	[NombreRecibidoPor] [nvarchar](300) NULL,	
	[Activo] [bit] NULL,
	[CreadoEl] [datetime] NULL,	
	[CreadorPor] [int] NULL,
	[ModificadoEl] [datetime] NULL,
	[ModificadoPor] [int] NULL
) 



