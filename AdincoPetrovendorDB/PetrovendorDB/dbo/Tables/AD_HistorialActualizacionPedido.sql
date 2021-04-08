CREATE TABLE [dbo].[AD_HistorialActualizacionPedido](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdPedido] [int] NULL,
	[ComentarioEditado] [nvarchar](max) NULL,
	[Responsable] [nvarchar](100) NULL,
	[Descripcion] [nvarchar](300) NULL,
	[TipoEdicion] [nvarchar](50) NULL,
	[Fecha] [datetime] NULL,
 CONSTRAINT [PK_AD_HistorialActualizacionPedido] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO