CREATE TABLE [dbo].[CN_OperadorasExcluidas](
	[IdOperadoraExcluidas] [int] IDENTITY(1,1) NOT NULL,
	[IdContrato] [int] NULL,
	[IdProveedor] [int] NULL,
	[Activo] [bit] NULL,
	[CreadoEl] [datetime] NULL,
	[ModificadoEl] [datetime] NULL
) ON [PRIMARY]
GO


