
CREATE TABLE [dbo].[AWS_DropboxCredenciales](
	[IdContrato] [int] NOT NULL,
	[AccessTokenValue] [varchar](max) NULL,
	[RootDefault] [varchar](max) NULL,
	[CreadoEl] [datetime] NULL,
	[CreadoPor] [int] NULL,
 CONSTRAINT [PK_AWS_DropboxCredenciales] PRIMARY KEY CLUSTERED 
(
	[IdContrato] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[AWS_DropboxCredenciales]  WITH CHECK ADD  CONSTRAINT [FK_AWS_DropboxCredenciales_AP_Usuario] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
GO

ALTER TABLE [dbo].[AWS_DropboxCredenciales] CHECK CONSTRAINT [FK_AWS_DropboxCredenciales_AP_Usuario]
GO

ALTER TABLE [dbo].[AWS_DropboxCredenciales]  WITH CHECK ADD  CONSTRAINT [FK_AWS_DropboxCredenciales_CO_Contrato] FOREIGN KEY([IdContrato])
REFERENCES [dbo].[CO_Contrato] ([IdContrato])
GO

ALTER TABLE [dbo].[AWS_DropboxCredenciales] CHECK CONSTRAINT [FK_AWS_DropboxCredenciales_CO_Contrato]
GO


