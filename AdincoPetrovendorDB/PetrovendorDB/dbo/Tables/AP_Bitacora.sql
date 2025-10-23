CREATE TABLE [dbo].[AP_Bitacora](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Fecha] [datetime] NULL,
	[Tipo] [varchar](1000) NULL,
	[Mensaje] [varchar](1000) NULL,
	[Detalle] NVARCHAR (MAX) NULL,
	[UsuarioId] [int] NULL,
	[ContratoId] [int] NULL,
 CONSTRAINT [PK_AP_Bitacora] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

