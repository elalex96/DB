CREATE TABLE [dbo].[CO_VerificacionCorreo](
	[IdVerificacionCorreo] [int] IDENTITY(100,1) NOT NULL,
	[IdUsuario] [int] NULL,
	[IdIdentificadorCorreo] [int] NULL,
	[Pantalla] [nvarchar](1000) NULL,
	[FechaVisto] [datetime] NULL
) ON [PRIMARY]
GO


