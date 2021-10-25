CREATE TYPE [dbo].[CARSO_ItemDetalle] AS TABLE(
	[LineaPresupuesto] [nvarchar](MAX) NULL,
	[IdLineaPresupuesto] Int,
	[IdPosicion] [nvarchar](max) NULL,
	[Item] [nvarchar](MAX) NULL,
	[Cantidad] [FLOAT] NULL,
	[Unidad] [nvarchar](max) NULL,
	[IdUnidad] Int,
	[LugarEntrega] [nvarchar](max) NULL,
	[IdInstalacion] int,
	[Instalacion] [nvarchar](max) NULL,
	[CentroCosto] [nvarchar](max) NULL,
	[IdCentroCosto] [nvarchar](max) NULL,
	[p1] [nvarchar](max) NULL,
	[p2] [nvarchar](max) NULL,
	[p3] [nvarchar](max) NULL,
	[p4] [nvarchar](max) NULL,
	[p5] [nvarchar](max) NULL
)
GO