USE [Adinco]
GO

/****** Object:  UserDefinedTableType [dbo].[Entregables_Importacion_01]    Script Date: 18/08/2021 01:39:31 p. m. ******/
CREATE TYPE [dbo].[Entregables_Importacion_01] AS TABLE(
	[IdEntregable] [nvarchar](50) NULL,
	[Area] [nvarchar](500) NULL,
	[DiasAlertaPrevia] [nvarchar](50) NULL,
	[DiasElaboracion] [nvarchar](50) NULL,
	[DiasRevicion] [nvarchar](50) NULL,
	[DiasAprobacion] [nvarchar](50) NULL,
	[Activo] [nvarchar](50) NULL,
	[Elaborador] [nvarchar](500) NULL,
	[Revisor] [nvarchar](500) NULL,
	[Aprobador] [nvarchar](500) NULL,
	[ReceptorAlerta] [nvarchar](500) NULL
)
GO


