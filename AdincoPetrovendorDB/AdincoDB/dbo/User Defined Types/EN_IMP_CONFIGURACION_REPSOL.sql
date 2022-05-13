USE [Adinco]
GO

/****** Object:  UserDefinedTableType [dbo].[Entregables_Importacion]    Script Date: 12/05/2022 01:53:36 p. m. ******/
CREATE TYPE [dbo].[EN_IMP_CONFIGURACION_REPSOL] AS TABLE(
	[IdEntregable] [nvarchar](100) NULL,
	[Area] [nvarchar](1000) NULL,
	[DiasAlertaPrevia] [nvarchar](100) NULL,
	[DiasElaboracion] [nvarchar](100) NULL,
	[DiasRevicion] [nvarchar](100) NULL,
	[DiasAprobacion] [nvarchar](100) NULL,
	[Activo] [nvarchar](10) NULL,
	[Elaborador] [nvarchar](1000) NULL,
	[ReceptorAlerta] [nvarchar](1000) NULL,
	[LiderArea] [nvarchar](1000) NULL,
	[ElaboradorInterno] [nvarchar](1000) NULL
)
GO


