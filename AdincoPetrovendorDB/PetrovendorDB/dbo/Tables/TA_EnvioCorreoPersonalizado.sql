CREATE TABLE [dbo].[TA_EnvioCorreoPersonalizado](
	[IdEnvioCorreo] [int] IDENTITY(1000,1) NOT NULL,
	[Correo] [varchar](200) NULL,
	[NombreDestinatario] [varchar](100) NULL,
	[IdUsuario] [int] NULL,
	[IdProveedor] [int] NULL,
	[IdContrato] [int] NULL,
	[TipoNotificacion] [nvarchar](50) NULL,
	[Activo] [bit] NULL,
	[CreadoEl] [datetime] NULL,
 CONSTRAINT [PK_TA_EnvioCorreoPersonalizado] PRIMARY KEY CLUSTERED 
(
	[IdEnvioCorreo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO