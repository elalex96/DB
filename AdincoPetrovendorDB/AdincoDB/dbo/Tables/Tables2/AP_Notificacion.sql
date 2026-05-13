
CREATE TABLE [dbo].[AP_Notificacion](
	[IdNotificacion] [bigint] NOT NULL,
	[Para] [varchar](3000) NULL,
	[Asunto] [varchar](500) NULL,
	[Mensaje] [text] NOT NULL,
	[FechaProgramadaEnvio] [datetime] NOT NULL,
	[Enviada] [bit] NOT NULL,
	[FechaEnvio] [datetime] NULL,
	[CreadoPor] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[ModificadoPor] [int] NULL,
	[ModificadoEl] [datetime] NULL,
	[De] [varchar](100) NULL,
	[EN_MsjEnviado] [bit] NULL,
	[CCO] [varchar](2000) NULL,
	[Modulo] [varchar](2000) NULL,
 CONSTRAINT [PK_AP_Notificacion] PRIMARY KEY CLUSTERED 
(
	[IdNotificacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[AP_Notificacion]  WITH CHECK ADD  CONSTRAINT [FK_AP_Notificacion_AP_Usuario] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
GO

ALTER TABLE [dbo].[AP_Notificacion] CHECK CONSTRAINT [FK_AP_Notificacion_AP_Usuario]
GO

ALTER TABLE [dbo].[AP_Notificacion]  WITH CHECK ADD  CONSTRAINT [FK_AP_Notificacion_AP_Usuario1] FOREIGN KEY([ModificadoPor])
REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
GO

ALTER TABLE [dbo].[AP_Notificacion] CHECK CONSTRAINT [FK_AP_Notificacion_AP_Usuario1]
GO