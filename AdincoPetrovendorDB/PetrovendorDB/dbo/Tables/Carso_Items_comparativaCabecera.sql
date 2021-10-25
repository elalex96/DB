CREATE TABLE Carso_Items_comparativaCabecera
(
	id int primary key not null identity(1,1),
	[FechaEntrega] [DATETIME] NULL,
	[TipoAdjudicacion] Int,
	[JustificacionPedido] [nvarchar](max) NULL,
	[Aprobadores] [nvarchar](MAX) NULL,
	[MensajeAprobacion] [nvarchar](MAX) NULL,
	[IdComparativa] [nvarchar](max) NULL,
	[p6] [nvarchar](max) NULL,
	[p7] [nvarchar](max) NULL,
	[p8] [nvarchar](max) NULL,
	[p9] [nvarchar](max) NULL,
	[p10] [nvarchar](max) NULL,
	[DataAreaID] [nvarchar](max) NULL,
	[Procesado] bit,
	Activo bit,
	CreadoEl datetime,
	ProcesadoEl datetime
)