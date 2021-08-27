CREATE TYPE [dbo].[Entregables_Importacion_SHELL] AS TABLE(
	[IdEntregable] [nvarchar](500) NULL,
	[Funcion] [nvarchar](500) NULL,
	[Subfuncion] [nvarchar](500) NULL,
	[DiasAlertaPrevia] [nvarchar](500) NULL,
	[DiasElaboracion] [nvarchar](500) NULL,
	[Activo] [nvarchar](500) NULL,
	[Elaborador] [nvarchar](500) NULL,
	[FocalPoint] [nvarchar](500) NULL,
	[Accountable] [nvarchar](500) NULL,
	[AccountableCompliance] [nvarchar](500) NULL,
	[Column16] [nvarchar](500) NULL
)
GO