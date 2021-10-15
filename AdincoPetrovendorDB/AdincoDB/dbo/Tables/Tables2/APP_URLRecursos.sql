CREATE TABLE [dbo].[APP_URLRecursos](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Tipo] [varchar](100) NULL,
	[Descripcion] [varchar](1500) NULL,
	[URL] [varchar](1500) NULL,
	[Activo] [bit] NOT NULL
) ON [PRIMARY]
GO