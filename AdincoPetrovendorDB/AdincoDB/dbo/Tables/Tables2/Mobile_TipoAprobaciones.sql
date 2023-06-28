USE [Adinco]
GO
/****** Object:  Table [dbo].[Mobile_TipoAprobaciones]    Script Date: 27/06/2023 10:17:54 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Mobile_TipoAprobaciones](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Menu] [varchar](200) NULL,
	[IdTitulo] [varchar](200) NULL,
	[Icon] [varchar](200) NULL,
	[IdTipoAprobacion] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[Mobile_TipoAprobaciones] ON 
GO
INSERT [dbo].[Mobile_TipoAprobaciones] ([Id], [Menu], [IdTitulo], [Icon], [IdTipoAprobacion]) VALUES (1, N'Requisici�n', N'REQUI_TTL', N'requi.png', 2)
GO
INSERT [dbo].[Mobile_TipoAprobaciones] ([Id], [Menu], [IdTitulo], [Icon], [IdTipoAprobacion]) VALUES (2, N'Aprobaci�n Pedido', N'PEDIDO_TTL', N'pedido.png', 9)
GO
INSERT [dbo].[Mobile_TipoAprobaciones] ([Id], [Menu], [IdTitulo], [Icon], [IdTipoAprobacion]) VALUES (3, N'Compra Directa', N'COMPRADIRECTA_TTL', N'compradirecta.png', 14)
GO
INSERT [dbo].[Mobile_TipoAprobaciones] ([Id], [Menu], [IdTitulo], [Icon], [IdTipoAprobacion]) VALUES (4, N'Pedimento/Comprobante', N'PEDIMENTO_COMPROBANTE_TTL', N'pedimentocomprobante.png', 19)
GO
SET IDENTITY_INSERT [dbo].[Mobile_TipoAprobaciones] OFF
GO
