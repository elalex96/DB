
CREATE TABLE [dbo].[DEA_UsuarioOBS](	
	[IdUsuario] [int] NOT NULL,
	[IdContrato] [int] NOT NULL,
	[CreadoEl] [Datetime] NOT NULL,
	[ModificadoEl]  [Datetime] NULL,
	[Activo] [BIT] NOT NULL
	CONSTRAINT [fk_DEA_UsuarioOBS_S_Usuario] FOREIGN KEY ([IdUsuario]) REFERENCES [dbo].[S_Usuario] ([IdUsuario]),
)

